import os, strformat, strutils

import mbr, sector, partition

proc displayBootStrapCode(c: BootStrapCode) =
  echo "boot strap code:\n  (skip)" # todo

proc displayPartitionBootFlag(f: PartitionBootFlags) =
  echo "  partition boot flag: " & int(f).toHex(2) & (if f == PartitionBootFlags.Bootable: "(Bootable)" else: "(Unbootable)")

proc displaySectorCHS(s: SectorCHS, headerStr: string) =
  let cylinderUpper2bit = int(s.cylinderUpper2bit_sector6bit shr 6) shl 8
  let cylinder = (cylinderUpper2bit or int(s.cylinderLower8bit))
  let sector = s.cylinderUpper2bit_sector6bit and 0b00111111
  echo "  " & headerStr
  echo "    cylinder: " & $cylinder
  echo "    head: " & $s.head
  echo "    sector: " & $sector

proc displaySectorLBA(s: SectorLBA, headerStr: string) =
  echo "  " & headerStr & "0x" & int(s).toHex(8) & "(" & $s & ")"

proc displayPartitionType(t: PartitionTypes) =
  echo "  partition type: " & int(t).toHex(2) & "(" & PartitionTypesStr[uint8(t)] & ")"

proc displaySectorCount(c: uint32) =
  echo "  sector count: " & $c & "(" & $(uint64(c) * 512) & " bytes)"

proc displayPartionTable(t: PartitionTable, headerStr: string) =
  if not isValidPartition(t):
    return
  echo headerStr
  displayPartitionBootFlag(t.bootFlag)
  displaySectorCHS(t.firstSectorCHS, "first sector (CHS): ")
  displayPartitionType(t.partitionType)
  displaySectorCHS(t.lastSectorCHS, "last sector (CHS): ")
  displaySectorLBA(t.firstSectorLBA, "first sector (LBA): ")
  displaySectorCount(t.sectorCount)

proc displayBootSignature*(s: BootSignature) =
  echo "boot signature: 0x" & $int(s[0]).toHex(2) & $int(s[1]).toHex(2) 

proc displayMasterBootRecord*(r: MasterBootRecord): void =
  displayBootStrapCode(r.code)
  displayPartionTable(r.partitionTable1, "partition table 1")
  displayPartionTable(r.partitionTable2, "partition table 2")
  displayPartionTable(r.partitionTable3, "partition table 3")
  displayPartionTable(r.partitionTable4, "partition table 4")
  displayBootSignature(r.bootSignature)