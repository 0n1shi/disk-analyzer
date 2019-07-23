type 
  PartitionBootFlags {.pure.} = enum
    Unbootable = 0x00
    Bootable = 0x80
  PartitionTypes {.pure.} = enum
    Empty = 0x00
    FAT12 = 0x01


type SectorInfoCHS = object
  head: uint8
  cylinderUpper2bit_sector6bit: uint8
  cylinderLower8bit: uint8

type BootStrapCode = array[446, uint8]

type MBR = object
    code: BootStrapCode

