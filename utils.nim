import posix, strutils, sequtils

proc exitWithErrorMsg*(msg: string): void {.noreturn.} =
  echo msg
  posix.exitnow(1)

proc hex*(val: uint16, prefix: bool): string =
  return (if prefix: "0x" else: "") & strutils.toHex(val)

proc hex*(val: uint8, prefix: bool): string =
  return (if prefix: "0x" else: "") & strutils.toHex(val)
