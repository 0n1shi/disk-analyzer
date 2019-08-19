import posix, strutils, sequtils, strformat

proc exitWithErrorMsg*(msg: string): void {.noreturn.} =
  echo msg
  posix.exitnow(1)

proc toString*(str: openarray[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

# 現在のブロック番号を表示(端数も表示)
proc getCurrentBlockNumber*(fd: cint, firstSector: Off, blocKSize: int): int =
  return ((lseek(fd, Off(0), SEEK_CUR) - firstSector) div blockSize)

# 現在のブロック番号を表示(端数も表示)
proc moveBlockNumber*(fd: cint, firstSector: Off, blocKSize: int, index: int): bool {.discardable.} =
  if lseek(fd, Off(firstSector + (index * blockSize)), SEEK_SET) == -1:
    return false
  return true