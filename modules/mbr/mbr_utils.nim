import os, strformat, strutils

import mbr
import ../../utils

proc displayPartitionBootFlag*(f: PartitionBootFlags) =
  echo "  partition boot flag: " & $hex(uint8(f), true) & (if f == PartitionBootFlags.Bootable: "(Bootable)" else: "(Unbootable)")

proc displaySectorCHS*(s: SectorCHS, headerStr: string) =
  let cylinderUpper2bit = int(s.cylinderUpper2bit_sector6bit shr 6) shl 8
  let cylinder = (cylinderUpper2bit or int(s.cylinderLower8bit))
  let sector = s.cylinderUpper2bit_sector6bit and 0b00111111
  echo "  " & headerStr
  echo "    cylinder: " & $cylinder
  echo "    head: " & $s.head
  echo "    sector: " & $sector

proc displaySectorLBA*(s: SectorLBA, headerStr: string) =
  echo "  " & headerStr & $hex(uint32(s), true) & "(" & $s & ")"

proc displayPartitionType*(t: PartitionTypes) =
  echo "  partition type: " & $hex(uint8(t), true) & "(" & PartitionTypesStr[uint8(t)] & ")"

proc displaySectorCount*(c: uint32) =
  echo "  sector count: " & $c

proc displayPartionTable*(t: PartitionTable, headerStr: string) =
  if uint8(t.bootFlag) == 0:
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
  displayPartionTable(r.partitionTable1, "partition table 1")
  displayPartionTable(r.partitionTable2, "partition table 2")
  displayPartionTable(r.partitionTable3, "partition table 3")
  displayPartionTable(r.partitionTable4, "partition table 4")
  displayBootSignature(r.bootSignature)