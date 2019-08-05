import posix, strutils, sequtils, strformat

proc exitWithErrorMsg*(msg: string): void {.noreturn.} =
  echo msg
  posix.exitnow(1)

proc toString*(str: openarray[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)