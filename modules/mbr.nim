type 
  PartitionBootFlags {.pure.} = enum
    Unbootable  = 0x00
    Bootable    = 0x80
  PartitionTypes {.pure.} = enum
    Empty                   = 0x00
    FAT12                   = 0x01
    FAT16_LE32MB            = 0x04
    ExtendedDOSArea         = 0x05
    FAT16_GT32MB            = 0x06
    HPFS_NTFS_exFAT         = 0x07
    FAT32                   = 0x0B
    FAT32_LBA               = 0x0C
    FAT16_LBA               = 0x0E
    ExtendedDOSArea_LBA     = 0x0F
    FAT12_2                 = 0x11
    BTRON3_FS               = 0x13
    FAT16_LE32MB_2          = 0x14
    ExtendedDOSArea_2       = 0x15
    FAT16_GT32MB_2          = 0x16
    HPFS_NTFS_exFAT_2       = 0x17
    FAT32_2                 = 0x1B
    FAT32_LBA_2             = 0x1C
    FAT16_LBA_2             = 0x1E
    ExtendedDOSArea_LBA_2   = 0x1F
    Plan9FS                 = 0x39
    EOTA_SFS                = 0x71
    Ext1                    = 0x81 # Minix File System
    SwapForLinux            = 0x82 # Before Solaris 10
    FSForLinux              = 0x83 # like ext2 etc
    LinuxExtendedArea       = 0x85
    SuspendedArea           = 0xA0
    FreeBSD_UFS             = 0xA5 # FFS/UFS1/UFS2
    OpenBSD_UFS             = 0xA6
    NetBSD_UFS              = 0xA9
    BootPartitionForSolaris = 0xBE
    FSForSolaris            = 0xBF
    DR_DOS_FS1              = 0xC1
    DR_DOS_FS2              = 0xC4
    DR_DOS_FS_GT_32MB       = 0xC6
    FSForBeOS               = 0xEB
    GPT                     = 0xEE
    EFISystemPartition      = 0xEF

type SectorCHS = object
  head: uint8
  cylinderUpper2bit_sector6bit: uint8
  cylinderLower8bit: uint8

type SectorLBA = uint32

type PartitionTable = object
  bootFlag: PartitionBootFlags
  firstSectorCHS: SectorCHS
  partitionType: PartitionTypes
  lastSecotrCHS: SectorCHS
  firstSectorLBA: SectorLBA
  sectorCount: uint32

type BootStrapCode = array[446, uint8]

type MBR = object
    code: BootStrapCode
    partitionTable1: PartitionTable
    partitionTable2: PartitionTable
    partitionTable3: PartitionTable
    partitionTable4: PartitionTable
    bootSignature: uint16


