import os
import posix
import strutils

import modules/mbr/mbr
import modules/mbr/mbr_utils
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
  var sectorData: sector
  let sdPtr: ptr sector = sectorData.addr
  let readCount: int = read(fd, sdPtr, SECTOR_SIZE)
  if readCount < 0:
    exitWithErrorMsg("failed to read file")

  let mbRecord = toMasterBootRecord(sectorData)
  displaySectorCHS(mbRecord.partitionTable1.firstSectorCHS)

main()
