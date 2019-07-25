import tables

const SECTOR_SIZE* = 512
type sector* = array[SECTOR_SIZE, uint8]

type
  PartitionBootFlags* {.pure.} = enum
    Unbootable  = 0x00'u8
    Bootable    = 0x80'u8
  PartitionTypes* {.pure.} = enum
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

const PartitionTypesStr* = {
  0x00: "Empty                  ",
  0x01: "FAT12                  ",
  0x04: "FAT16_LE32MB           ",
  0x05: "ExtendedDOSArea        ",
  0x06: "FAT16_GT32MB           ",
  0x07: "HPFS_NTFS_exFAT        ",
  0x0B: "FAT32                  ",
  0x0C: "FAT32_LBA              ",
  0x0E: "FAT16_LBA              ",
  0x0F: "ExtendedDOSArea_LBA    ",
  0x11: "FAT12                  ",
  0x13: "BTRON3_FS              ",
  0x14: "FAT16_LE32MB           ",
  0x15: "ExtendedDOSArea        ",
  0x16: "FAT16_GT32MB           ",
  0x17: "HPFS_NTFS_exFAT        ",
  0x1B: "FAT32                  ",
  0x1C: "FAT32_LBA              ",
  0x1E: "FAT16_LBA              ",
  0x1F: "ExtendedDOSArea_LBA    ",
  0x39: "Plan9FS                ",
  0x71: "EOTA_SFS               ",
  0x81: "Ext1                   ", # Minix File System
  0x82: "SwapForLinux           ", # Before Solaris 10
  0x83: "FSForLinux             ", # like ext2 etc
  0x85: "LinuxExtendedArea      ",
  0xA0: "SuspendedArea          ",
  0xA5: "FreeBSD_UFS            ", # FFS/UFS1/UFS2
  0xA6: "OpenBSD_UFS            ",
  0xA9: "NetBSD_UFS             ",
  0xBE: "BootPartitionForSolaris",
  0xBF: "FSForSolaris           ",
  0xC1: "DR_DOS_FS1             ",
  0xC4: "DR_DOS_FS2             ",
  0xC6: "DR_DOS_FS_GT_32MB      ",
  0xEB: "FSForBeOS              ",
  0xEE: "GPT                    ",
  0xEF: "EFISystemPartition     ",
}.toTable

const PartitionTypeStrings: seq[string] = @[
  "Empty", "FAT12", "FAT16 less than 32MB", "unknown", ""
]

type SectorCHS* = object
  head*                          : uint8
  cylinderUpper2bit_sector6bit*  : uint8
  cylinderLower8bit*             : uint8

type SectorLBA* = uint32

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

const BootStrapCodeSize* = 446
type BootStrapCode* = array[BootStrapCodeSize, uint8]

type MasterBootRecord* = object
    code*: BootStrapCode
    partitionTable1*: PartitionTable
    partitionTable2*: PartitionTable
    partitionTable3*: PartitionTable
    partitionTable4*: PartitionTable
    bootSignature*: uint16

proc toSectorCode*(data: seq[uint8]): BootStrapCode =
  var code: BootStrapCode
  let bootStrapCodeSize = sizeof(BootStrapCode)
  for i in 0..<bootStrapCodeSize:
    code[i] = data[i]
  return code

proc toPartitionTable*(data: seq[uint8]): PartitionTable =
  let bootFlag = PartitionBootFlags(data[0])
  let firstSectorCHS = SectorCHS(
    head: data[0x01],
    cylinderUpper2bit_sector6bit: data[0x02],
    cylinderLower8bit: data[0x03]
  )
  let partitionType = PartitionTypes(data[0x04])
  let lastSectorCHS = SectorCHS(
    head: data[0x05],
    cylinderUpper2bit_sector6bit: data[0x06],
    cylinderLower8bit: data[0x07]
  )
  let firstSectorLBA = cast[SectorLBA](data[0x08..0xB])

  return PartitionTable(
    bootFlag: bootFlag,
    firstSectorCHS: firstSectorCHS,
    partitionType: partitionType,
    lastSectorCHS: lastSectorCHS,
    firstSectorLBA: firstSectorLBA,
  )

proc toMasterBootRecord*(data: sector): MasterBootRecord =
  let code: BootStrapCode = toSectorCode(data[0..BootStrapCodeSize - 1])
  let table1: PartitionTable = toPartitionTable(data[Partition1Index..(EndOfPartition1)])
  let table2: PartitionTable = toPartitionTable(data[Partition2Index..(EndOfPartition2)])
  let table3: PartitionTable = toPartitionTable(data[Partition3Index..(EndOfPartition3)])
  let table4: PartitionTable = toPartitionTable(data[Partition4Index..(EndOfPartition4)])
  return MasterBootRecord(
    code: code,
    partitionTable1: table1,
    partitionTable2: table2,
    partitionTable3: table3,
    partitionTable4: table4,
    bootSignature: cast[uint16](data[0x01FE..0x01FF]),
  )
