import os
import posix
import strutils

import modules/mbr

const SECTOR_SIZE = 512
type sector = array[SECTOR_SIZE, uint8]

proc exitWithErrorMsg(msg: string): void {.noreturn.}=
  echo msg
  posix.exitnow(1)

proc main() =
  # get a file name
  if os.paramCount() < 1:
    exitWithErrorMsg("expect filename")
  let filename = os.paramStr(1)

  # open the file
  var fd = posix.open(filename, 0)
  if fd == -1:
    exitWithErrorMsg("can't open file")
  
  # read first sector
  var sectorData: sector
  let sdPtr: ptr sector = sectorData.addr
  let readCount = posix.read(fd, sdPtr, SECTOR_SIZE)
  if readCount < 0:
    exitWithErrorMsg("failed to read file")

  echo strutils.toHex(sectorData[511])

main()
