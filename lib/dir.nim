const EXT2_NAME_LEN = 255
type dirEntryFileName* = array[EXT2_NAME_LEN, char]

type fileType = enum
  EXT2_FT_UNKNOWN   = 0
  EXT2_FT_REG_FILE  = 1
  EXT2_FT_DIR       = 2
  EXT2_FT_CHRDEV    = 3
  EXT2_FT_BLKDEV    = 4
  EXT2_FT_FIFO      = 5
  EXT2_FT_SOCK      = 6
  EXT2_FT_SYMLINK   = 7
  EXT2_FT_MAX       = 8
var fileTypeStr* = [
  "unknown",
  "regular",
  "directory",
  "charactor device",
  "block device",
  "buffer file",
  "socket",
  "symbolic link"
]

type Ext2DirEntry* = object
  inodeNumber*  : uint32
  entryLength*  : uint16
  nameLength*   : uint8
  fileType*     : uint8

proc actualNameLength*(len: int): int =
  return len + (4 - (len mod 4))