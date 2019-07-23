type 
  PartitionBootFlags {.pure.} = enum
    Unbootable = 0x00
    Bootable = 0x80
  PartitionTypes {.pure.} = enum
    Empty = 0x00
    FAT12 = 0x01
    FAT16_LE32MB = 0x04
    ExtendedDOSArea = 0x05
    FAT16_GT32MB = 0x06
    HPFS_NTFS_exFAT = 0x07
    FAT32 = 0x0B
    FAT32_LBA = 0x0C
    FAT16_LBA = 0x0E
    ExtendedDOSArea_LBA = 0x0F
    _FAT12 = 0x11
    BTRON3_FS = 0x13
    _FAT16_LE32MB = 0x14
    _ExtendedDOSArea = 0x15
    _FAT16_GT32MB = 0x16
    _HPFS_NTFS_exFAT = 0x17
    _FAT32 = 0x1B
    _FAT32_LBA = 0x1C
    _FAT16_LBA = 0x1E
    _ExtendedDOSArea_LBA = 0x1F
    Plan9FS = 0x39
    EOTA_SFS = 0x71
    Ext1 = 0x81 # Minix File System
    SwapForLinux = 0x82 # Before Solaris 10





type SectorInfoCHS = object
  head: uint8
  cylinderUpper2bit_sector6bit: uint8
  cylinderLower8bit: uint8

type BootStrapCode = array[446, uint8]

type MBR = object
    code: BootStrapCode

