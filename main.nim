import os
import posix
import strutils, sequtils, strformat

import lib/mbr/mbr
import lib/mbr/mbr_utils
import lib/partition/ext2
import utils

proc toString(str: openarray[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

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

  echo ""

  # partition table 1
  if isValidPartition(mbRecord.partitionTable1):
    # get start of partition
    echo "partition table 1"
    let firstSector = getFirstByteOfPartition(mbRecord.partitionTable1)

    # read book block
    if lseek(fd, Off(firstSector), SEEK_CUR) == -1:
      exitWithErrorMsg("failed to seek file descriptor")
    var bootBlock: BootBlock
    readCount = read(fd, bootBlock.addr, SECTOR_SIZE)
    if readCount < 0:
      exitWithErrorMsg("failed to read file")

    # read ext2 super block
    var ext2SuperBlock: Ext2SuperBlock
    readCount = read(fd, ext2SuperBlock.addr, sizeof(Ext2SuperBlock))
    if readCount < 0:
      exitWithErrorMsg("failed to read file")


    echo "* number of inodes: " & $ext2SuperBlock.inodesCount
    echo "* number of blocks: " & $ext2SuperBlock.blocksCount
    echo "* size of block: " & $ext2SuperBlock.blockSize
    echo "* magic signature: 0x" & $int(ext2SuperBlock.magicSignature).toHex(4)

main()
