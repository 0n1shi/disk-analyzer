import os
import posix
import strutils, sequtils, strformat

import lib/mbr/mbr
import lib/mbr/mbr_utils
import lib/partition/ext2
import lib/partition/ext2_utils
import utils

# get a file name
if paramCount() < 1:
  exitWithErrorMsg("expect filename")
let filename = paramStr(1)

# open the file
var fd: cint = open(filename, 0)
if fd == -1:
  exitWithErrorMsg("can't open file")

# read first sector
var mbRecord: MasterBootRecord
var readCount: int = read(fd, mbRecord.addr, sizeof(MasterBootRecord))
if readCount < 0:
  exitWithErrorMsg("failed to read file")

# show information of Master Boot Record
displayMasterBootRecord(mbRecord)
echo "" # new line

# partition table 1
if isValidPartition(mbRecord.partitionTable1):
  # get start of partition
  echo "partition table 1 (superblock)"
  let firstSector = getFirstByteOfPartition(mbRecord.partitionTable1)

  # go to first sector in the partition
  if lseek(fd, Off(firstSector), SEEK_SET) == -1:
    exitWithErrorMsg("failed to seek file descriptor")

  # read boot block
  var bootBlock: BootBlock
  readCount = read(fd, bootBlock.addr, sizeof(BootBlock))
  if readCount < 0:
    exitWithErrorMsg("failed to read file")

  # read ext2 super block
  var ext2SuperBlock: Ext2SuperBlock
  readCount = read(fd, ext2SuperBlock.addr, sizeof(Ext2SuperBlock))
  if readCount < 0:
    exitWithErrorMsg("failed to read file")
  
  
  # display ext super block
  let blockSize = BLOCK_SIZE_BASE shl ext2SuperBlock.blockSize
  echo "  - number of inodes: " & $ext2SuperBlock.inodesCount
  echo "  - number of blocks: " & $ext2SuperBlock.blocksCount
  echo "  - size of block: " & $blockSize
  echo "  - magic signature: 0x" & $int(ext2SuperBlock.magicSignature).toHex(4)
  echo "  - last mounted path: " & toString(ext2SuperBlock.lastMountedDirectory)
  echo "" # new line

  # go to first block of group descripor table
  if lseek(fd, Off(BLOCK_SIZE_BASE*2), SEEK_CUR) == -1:
    exitWithErrorMsg("failed to seek file descriptor")
  
  # read ext2 group descriptor table
  var ext2GroupDescriptorList: seq[Ext2GroupDescriptor]
  for i in 0..<int(blockSize/BLOCK_SIZE_BASE):
    var buffer : array[BLOCK_SIZE_BASE, uint8]
    readCount = read(fd, buffer.addr, BLOCK_SIZE_BASE)
    if readCount < 0:
      exitWithErrorMsg("failed to read file")
    for j in 0..<int(BLOCK_SIZE_BASE/Ext2GroupDescriptorSize):
      let bufferIndex = j * Ext2GroupDescriptorSize
      let lastBufferIndex = bufferIndex + Ext2GroupDescriptorSize - 1
      var ext2GroupDescriptorSizeBuffer : array[Ext2GroupDescriptorSize, uint8]
      ext2GroupDescriptorList.add(toGroupDescriptor(buffer[bufferIndex..lastBufferIndex]))
  
  # display block group descriptor table
  echo "  - block group descriptor table"
  for i, item in ext2GroupDescriptorList.pairs:
    if item.freeBlocksCount == 0:
      break
    echo "    group no." & $i
    echo "      - free blocks count: " & $item.freeBlocksCount
    echo "      - free inodes count: " & $item.freeInodesCount
    echo "      - used dirs count: " & $item.usedDirectoriesCount
  echo "" # newline

  # read block bitmap
  var blockBitmap: BlockBitMap 
  for i in 0..<int(blockSize/BLOCK_SIZE_BASE):
    var buffer : array[BLOCK_SIZE_BASE, uint8]
    readCount = read(fd, buffer.addr, BLOCK_SIZE_BASE)
    if readCount < 0:
      exitWithErrorMsg("failed to read block bitmap")
    for j in 0..<BLOCK_SIZE_BASE:
      blockBitmap.add(buffer[j])

  # display block bitmap
  echo "    - block bitmap"
  for i in 0..<int(blockSize/16):
    let base = i * 16
    var outputStr = "      0x" & base.toHex(2) & " "
    for j in 0..<16:
      outputStr &= int(blockBitmap[base + j]).toHex(2)
      if j mod 2 == 1:
        outputStr &= " "
    echo outputStr
  echo "" # new line

  # read inode bitmap
  var inodeBitmap: InodeBitMap 
  for i in 0..<blockSize div BLOCK_SIZE_BASE:
    var buffer : array[BLOCK_SIZE_BASE, uint8]
    readCount = read(fd, buffer.addr, BLOCK_SIZE_BASE)
    if readCount < 0:
      exitWithErrorMsg("failed to read inode bitmap")
    for j in 0..<BLOCK_SIZE_BASE:
      inodeBitmap.add(buffer[j])

  # display inode bitmap
  echo "    - inode bitmap"
  for i in 0..<blockSize div 16:
    let base = i * 16
    var outputStr = "      0x" & base.toHex(2) & " "
    for j in 0..<16:
      outputStr &= int(inodeBitmap[base + j]).toHex(2)
      if j mod 2 == 1:
        outputStr &= " "
    echo outputStr
  
  # read inode table
  var inodeTable : seq[Ext2Inode]
  for i in 0..<inodeTableBlockCount:
    for j in 0..<(blockSize div Ext2InodeSize):
      var ext2Inode : Ext2Inode
      readCount = read(fd, ext2Inode.addr, Ext2InodeSize)
      if readCount < 0:
        exitWithErrorMsg("failed to read inode table")
      inodeTable.add(ext2Inode)
  
  # display inodes
  echo "    - inode table"
  for i in 0..<len(inodeTable):
    let inode = inodeTable[i]
    let mode = int(inode.fileMode)
    if isRegularFile(mode):
      echo "      - No." & $i
      echo "        - file mode: " & displayFileMode(mode)
      echo "        - uid : " & $((inode.uidHigh shl 16)  or inode.uid)
      echo "        - access time : " & $inode.accessTime
      echo "        - creation time : " & $inode.creationTime
      echo "        - link count : " & $inode.linksCount