import posix, strutils, sequtils, strformat

proc exitWithErrorMsg*(msg: string): void {.noreturn.} =
  echo msg
  posix.exitnow(1)