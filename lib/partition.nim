import strutils

import sector

type PartitionBootFlags* {.pure.} = enum
  Unbootable  = 0x00'u8
  Bootable    = 0x80'u8

type PartitionTypes* {.pure.} = enum
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

const PartitionTypesStr* = [
  "Empty",
  "FAT12",
  "unknown",
  "unknown",
  "FAT16 lt 32MB",
  "Extended DOS area",
  "FAT16 gt 32MB",
  "HPFS or NTFS or exFAT",
  "unknown",
  "unknown",
  "unknown",
  "FAT32",
  "FAT32 LBA",
  "unknown",
  "FAT16 LBA",
  "Extended DOS area LBA",
  "unknown",
  "FAT12",
  "unknown",
  "BTRON3 FS",
  "FAT16 lt 32MB",
  "Extended DOS area",
  "FAT16 gt 32MB",
  "HPFS or NTFS or exFAT",
  "unknown",
  "unknown",
  "unknown",
  "FAT32",
  "FAT32 LBA",
  "unknown",
  "FAT16 LBA",
  "Extended DOS area LBA",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "File System for Plan9",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "EOTA SFS",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "Minix file system", # Minix File System
  "Swap area for Linux", # Before Solaris 10
  "File System For Linux", # like ext2 etc
  "unknown",
  "Linux extended area",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "Suspended area",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "FreeBSD Unix File System", # FFS/UFS1/UFS2
  "OpenBSD Unix File System",
  "unknown",
  "unknown",
  "NetBSD Unix File System",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "Boot partition for Solaris",
  "File System for Solaris",
  "unknown",
  "DR DOS FS1",
  "unknown",
  "unknown",
  "DR DOS FS2",
  "unknown",
  "DR DOS FS gt 32MB",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "unknown",
  "File System for BeOS",
  "unknown",
  "unknown",
  "GPT",
  "EFI System Partition",
]

type PartitionTable* = object
  bootFlag*       : PartitionBootFlags
  firstSectorCHS* : SectorCHS
  partitionType*  : PartitionTypes
  lastSectorCHS*  : SectorCHS
  firstSectorLBA* : SectorLBA
  sectorCount*    : uint32
const
  Partition1Index*  = 0x01BE
  Partition2Index*  = 0x01CE
  Partition3Index*  = 0x01DE
  Partition4Index*  = 0x01EE
let PartitionTableSize* = sizeof(PartitionTable)
let
  EndOfPartition1* = Partition1Index + PartitionTableSize - 1
  EndOfPartition2* = Partition2Index + PartitionTableSize - 1
  EndOfPartition3* = Partition3Index + PartitionTableSize - 1
  EndOfPartition4* = Partition4Index + PartitionTableSize - 1

proc isValidPartition*(t: PartitionTable): bool =
  return if t.sectorCount != 0: true else: false

proc getFirstByteOfPartition*(t: PartitionTable): uint64 =
  return uint64(t.firstSectorLBA) * uint64(SECTOR_SIZE)