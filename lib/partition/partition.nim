import strutils

type BootBlock = array[0x400, char]
type Ext2SuperBlock = object
  InodeCount : uint32
  BlockCount : uint32
  ReservedBlockCount : uint32
  FreeBlockCount : uint32
  FreeInodeCount : uint32
  FirstDataBlock : uint32
  BlockSize : uint32
  FlagmentSize : uint32
