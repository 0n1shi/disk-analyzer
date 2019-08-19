import os
import posix
import strutils, sequtils, strformat

import lib/mbr
import lib/mbr_utils
import lib/partition
import lib/ext2
import lib/ext2_utils
import lib/dir
import utils

if paramCount() < 1:
  exitWithErrorMsg("expect filename")
let filename = paramStr(1)

var fd: cint = open(filename, 0)
if fd == -1:
  exitWithErrorMsg("can't open file")

# 先頭セクタを読み込み
var mbRecord: MasterBootRecord
var readCount: int = read(fd, mbRecord.addr, sizeof(MasterBootRecord))
if readCount < 0:
  exitWithErrorMsg("failed to read file")

# マスターブートレコードの情報を表示
displayMasterBootRecord(mbRecord)
echo ""

# パーティションテーブル1
if isValidPartition(mbRecord.partitionTable1):
  # パーティションの先頭セクタ位置をパーティションテーブルから取得
  echo "partition table 1 (superblock):"
  let firstSector = getFirstByteOfPartition(mbRecord.partitionTable1)

  # パーティションの先頭セクタに移動
  var partitionFirstSector = lseek(fd, Off(firstSector), SEEK_SET)
  if partitionFirstSector == -1:
    exitWithErrorMsg("failed to seek file descriptor")

  # スーパーブロックはディスクまたはパーティションの先頭から1024バイトの位置に存在するため移動  
  if lseek(fd, Off(BLOCK_SIZE_BASE), SEEK_CUR) == -1:
    exitWithErrorMsg("failed to seek file descriptor")

  # ext2のスーパーブロックを読み込み
  var ext2SuperBlock: Ext2SuperBlock
  readCount = read(fd, ext2SuperBlock.addr, sizeof(Ext2SuperBlock))
  if readCount < 0:
    exitWithErrorMsg("failed to read file")
  
  # スーパーブロックの情報の取得及び算出
  let blockSize = BLOCK_SIZE_BASE shl ext2SuperBlock.blockSize
  let numberOfBlockGroup = blockGroupCount(ext2SuperBlock)
  let blockDescriptorTableSize = blockDescriptorTableSize(numberOfBlockGroup)
  let groupDescriptorTableBlockCount = groupDescriptorTableBlockCount(blockDescriptorTableSize, blockSize)
  let inodesPerBlock = inodeCountPerBlock(blockSize)
  let inodeBlocksPerGroup = inodeBlocksPerGroup(ext2SuperBlock.inodesPerGroup, inodesPerBlock)
  
  # スーパーブロックの情報を表示
  echo "  number of inodes: " & $ext2SuperBlock.inodesCount
  echo "  number of blocks: " & $ext2SuperBlock.blocksCount
  echo "  size of block: " & $blockSize
  echo "  magic signature: 0x" & $int(ext2SuperBlock.magicSignature).toHex(4)
  echo "  last mounted path: " & toString(ext2SuperBlock.lastMountedDirectory)
  echo "  revision level: " & $ext2SuperBlock.revisionLevel
  echo "  inodes per block: " & $inodesPerBlock
  echo "  inodes per group: " & $ext2SuperBlock.inodesPerGroup
  echo "  blocks per group: " & $ext2SuperBlock.blocksPerGroup
  echo "  inode blocks per group: " & $inodeBlocksPerGroup
  echo "  blockDescriptorTableSize: " & $blockDescriptorTableSize
  echo "  numberOfBlockGroup: " & $numberOfBlockGroup
  echo "  groupDescriptorTableBlockCount: " & $groupDescriptorTableBlockCount
  echo "" # new line

  # ブロックグループディスクリプタテーブルはスーパーブロック後の次のブロックに存在するため移動する。
  # 計算式: ブロックサイズ - (スーパーブロックのサイズ + スーパーブロックのオフセット) = 次のブロックの開始位置 = ブロックグループディスクリプタ
  if lseek(fd, Off(blockSize - (sizeof(Ext2SuperBlock) + BLOCK_SIZE_BASE)), SEEK_CUR) == -1:
    exitWithErrorMsg("failed to seek file descriptor")
  
  # グループディスクリプタテーブルの読み込み(ブロックサイズ単位)
  var ext2GroupDescriptorList: seq[Ext2GroupDescriptor]
  for i in 0..<((groupDescriptorTableBlockCount * blockSize) div Ext2GroupDescriptorSize):
    var descriptor: Ext2GroupDescriptor
    readCount = read(fd, descriptor.addr, sizeof(Ext2GroupDescriptor))
    if readCount < 0:
      exitWithErrorMsg("failed to read file")
    ext2GroupDescriptorList.add(descriptor)
  
  # ブロックグループディスクリプタテーブルの表示
  echo "  block group descriptor table:"
  let blocksPerGroup = int(ext2SuperBlock.blocksPerGroup)
  for index, desc in ext2GroupDescriptorList.pairs:
    # ブロックグループの末尾まで表示が完了している
    if index >= numberOfBlockGroup:
      break
    # 当該ブロックグループの先頭及び末尾ブロック番号を算出
    let startBlock = index * blocksPerGroup
    var endBlock = (index*blocksPerGroup)+(blocksPerGroup-1)
    if endBlock >= int(ext2SuperBlock.blocksCount):
      endBlock = int(ext2SuperBlock.blocksCount-1)
    # スーパーブロック及びブロックグループディスクリプタを含んでいるか、バックアップかどうか
    let isPrimaryBlock = startBlock == 0
    var hasSuperBlock = false
    if startBlock != int(desc.blocksBitmapBlock):
      hasSuperBlock = true # スーパーブロックが存在する場合にはグループディスクリプタ及びGDT予約ブロックも存在する
    let dataBlock = $(int(desc.inodesTableBlock) + inodeBlocksPerGroup)
    echo "    no." & $index & " (" & $(startBlock) & " ~ " & $(endBlock) & "):"
    if hasSuperBlock:
      if isPrimaryBlock:
        echo "      primary super block: " & $startBlock
      else:
        echo "      backup super block: " & $startBlock
      echo "      group descriptor table: " & $(startBlock + 1)
      echo "      reserved gdt block: " & $(startBlock + 1 + groupDescriptorTableBlockCount)
    echo "      block bitmap block: " & $desc.blocksBitmapBlock
    echo "      inodes bitmap block: " & $desc.inodesBitmapBlock
    echo "      inodes table block: " & $desc.inodesTableBlock
    echo "      data block: " & $dataBlock
    echo "      free blocks count: " & $desc.freeBlocksCount
    echo "      free inodes count: " & $desc.freeInodesCount
    echo "      used dirs count: " & $desc.usedDirectoriesCount
  echo ""
  
  # グループディスクリプタテーブルから各グループ内のブロックビットマップ、inodeビットマップ及びinodeテーブルを表示
  var rootDirDataBlock: int
  var sizeInBytes: int
  for index, desc in ext2GroupDescriptorList.pairs:
    # ブロックグループの末尾まで表示が完了している
    if index >= numberOfBlockGroup:
      break
    # 当該ブロックグループの先頭及び末尾ブロック番号を算出
    let startBlock = index * blocksPerGroup
    var endBlock = (index*blocksPerGroup)+(blocksPerGroup-1)
    if endBlock >= int(ext2SuperBlock.blocksCount):
      endBlock = int(ext2SuperBlock.blocksCount-1)
    # スーパーブロック及びブロックグループディスクリプタを含んでいるか、バックアップかどうか
    let isPrimaryBlock = startBlock == 0
    var hasSuperBlock = false
    if startBlock != int(desc.blocksBitmapBlock):
      hasSuperBlock = true # スーパーブロックが存在する場合にはグループディスクリプタ及びGDT予約ブロックも存在する
    
    # ブロックビットマップの位置まで移動する(GDT予約テーブルが存在する可能性がある)
    moveBlockNumber(fd, partitionFirstSector, blockSize, int(desc.blocksBitmapBlock))
    
    # ブロックビットマップの読み込み
    var blockBitmap: BlockBitMap
    for i in 0..<int(blockSize/BLOCK_SIZE_BASE):
      var buffer : array[BLOCK_SIZE_BASE, uint8]
      readCount = read(fd, buffer.addr, BLOCK_SIZE_BASE)
      if readCount < 0:
        exitWithErrorMsg("failed to read block bitmap")
      for j in 0..<BLOCK_SIZE_BASE:
        blockBitmap.add(buffer[j])
      
    # ブロックビットマップの表示
    echo "    block bitmap"
    for i in 0..<int(blockSize/16):
      let base = i * 16
      var outputStr = "      0x" & base.toHex(4) & " "
      for j in 0..<16:
        outputStr &= int(blockBitmap[base + j]).toHex(2)
        if j mod 2 == 1:
          outputStr &= " "
      echo outputStr
    echo ""
    
    # inodeビットマップの読み込み
    var inodeBitmap: InodeBitMap 
    for i in 0..<blockSize div BLOCK_SIZE_BASE:
      var buffer : array[BLOCK_SIZE_BASE, uint8]
      readCount = read(fd, buffer.addr, BLOCK_SIZE_BASE)
      if readCount < 0:
        exitWithErrorMsg("failed to read inode bitmap")
      for j in 0..<BLOCK_SIZE_BASE:
        inodeBitmap.add(buffer[j])
    
    # inodeビットマップの表示
    echo "    inode bitmap"
    for i in 0..<blockSize div 16:
      let base = i * 16
      var outputStr = "      0x" & base.toHex(4) & " "
      for j in 0..<16:
        outputStr &= int(inodeBitmap[base + j]).toHex(2)
        if j mod 2 == 1:
          outputStr &= " "
      echo outputStr
    echo ""

    # inodeテーブルの読み込み
    var inodeTable : seq[Ext2Inode]
    for i in 0..<inodeBlocksPerGroup:
      for j in 0..<inodesPerBlock:
        var ext2Inode : Ext2Inode
        readCount = read(fd, ext2Inode.addr, Ext2InodeSize)
        if readCount < 0:
          exitWithErrorMsg("failed to read inode table")
        inodeTable.add(ext2Inode)
    
    # display inodes
    echo "    inode table (" & $len(inodeTable) & ")"
    for i in 0..<len(inodeTable):
      let inode = inodeTable[i]
      let mode = int(inode.fileMode)
      echo "      - inode no." & $(i+1)
      echo "        - file mode: " & displayFileMode(mode)
      echo "        - uid : " & $((inode.uidHigh shl 16)  or inode.uid)
      echo "        - access time : " & $inode.accessTime
      echo "        - creation time : " & $inode.creationTime
      echo "        - link count : " & $inode.linksCount
      echo "        - first data block : " & $inode.pointersToBlocks[0]
      if i == 1:
        rootDirDataBlock = int(inode.pointersToBlocks[0])
        sizeInBytes = int(inode.sizeInBytes)
      if i >= 10:
        break
    echo "" # newline
    
    break # ブロックグループ0のみを表示対象とする

  moveBlockNumber(fd, partitionFirstSector, blockSize, rootDirDataBlock)

  var totalSize = 0
  while totalSize < sizeInBytes:
    var dir: Ext2DirEntry
    readCount = read(fd, dir.addr, sizeof(Ext2DirEntry))
    if readCount == -1:
      exitWithErrorMsg("failed to read inode table")
    
    echo "inodeNumber: " & $dir.inodeNumber
    echo "entryLength: " & $dir.entryLength
    echo "nameLength: " & $dir.nameLength
    echo "fileType: " & fileTypeStr[dir.fileType]

    var fileName: dirEntryFileName
    let nameLength = int(dir.entryLength) - sizeof(Ext2DirEntry)
    readCount = read(fd, fileName.addr, nameLength)
    if readCount == -1:
      exitWithErrorMsg("failed to read inode table")
    echo "fileName: " & toString(fileName)
    totalSize += int(dir.entryLength)
    echo ""
  
  echo totalSize