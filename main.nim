import os
import posix
import strutils, sequtils, strformat

import lib/mbr/mbr
import lib/mbr/mbr_utils
import lib/partition/ext2
import utils

proc main() =
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
    echo "partition table 1"
    let firstSector = getFirstByteOfPartition(mbRecord.partitionTable1)

    # go to first sector
    if lseek(fd, Off(firstSector), SEEK_SET) == -1:
      exitWithErrorMsg("failed to seek file descriptor")

    var bootBlock: BootBlock
    readCount = read(fd, bootBlock.addr, sizeof(BootBlock))
    if readCount < 0:
      exitWithErrorMsg("failed to read file")

    # read ext2 super block
    var ext2SuperBlock: Ext2SuperBlock
    readCount = read(fd, ext2SuperBlock.addr, sizeof(Ext2SuperBlock))
    if readCount < 0:
      exitWithErrorMsg("failed to read file")
    
    let blockSize = BLOCK_SIZE shl ext2SuperBlock.blockSize
    echo "* number of inodes: " & $ext2SuperBlock.inodesCount
    echo "* number of blocks: " & $ext2SuperBlock.blocksCount
    echo "* size of block: " & $blockSize
    echo "* magic signature: 0x" & $int(ext2SuperBlock.magicSignature).toHex(4)
    
    #echo blockSize - sizeof(BootBlock)
    #if lseek(fd, Off(blockSize - sizeof(BootBlock)), SEEK_CUR) == -1:
    #  exitWithErrorMsg("failed to seek file descriptor")
    
    let numberOfGroupDescriptors = int(blockSize / sizeof(Ext2GroupDescriptor))
    var list : Ext2GroupDescriptorList
    readCount = read(fd, list.addr, 4096)
    if readCount < 0:
      exitWithErrorMsg("failed to read file")

    echo ""
    
    for index, item in list.pairs:
      echo "group no." & $index
      echo "  * free blocks count: " & $item.freeBlocksCount
      echo "  * free inodes count: " & $item.freeInodesCount
      break
main()
