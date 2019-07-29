import os
import posix
import strutils, sequtils

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

  # Partition table 1
  if isValidPartition(mbRecord.partitionTable1):
    echo "partition table 1"
    let firstSector = getFirstByteOfPartition(mbRecord.partitionTable1)
    if lseek(fd, Off(firstSector), SEEK_CUR) == -1:
      exitWithErrorMsg("failed to seek file descriptor")
    var bootBlock: BootBlock
    readCount = read(fd, bootBlock.addr, SECTOR_SIZE)
    if readCount < 0:
      exitWithErrorMsg("failed to read file")
    var ext2SuperBlock: Ext2SuperBlock
    readCount = read(fd, ext2SuperBlock.addr, sizeof(Ext2SuperBlock))
    if readCount < 0:
      exitWithErrorMsg("failed to read file")
    echo "number of inode: " & $ext2SuperBlock.inodeCount
    echo "last mounted dir: " & ext2SuperBlock.lastMountedDirectory.mapIt(string, $it).join
    
    
main()