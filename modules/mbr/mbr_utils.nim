import os, strformat

import mbr
import ../../utils

proc displayPartitionBootFlag*(f: PartitionBootFlags) =
  displayTableRow("partition boot flag", hex(uint8(f), true))

proc displaySectorCHS*(s: SectorCHS, headerStr: string) =
  let cylinderUpper2bit = ((s.cylinderUpper2bit_sector6bit shr 6) shl 8)
  let cylinder = (cylinderUpper2bit or s.cylinderLower8bit)
  let sector = s.cylinderUpper2bit_sector6bit and 0b00111111
  displayTableHeader(headerStr)
  displayTableSeperater()
  displayTableRow("cylinder", hex(cylinder, true))
  displayTableRow("head", hex(s.head, true))
  displayTableRow("sector", hex(sector, true))

proc displaySectorLBA*(s: SectorLBA, headerStr: string) =
  displayTableHeader(headerStr)
  displayTableSeperater()
  displayTableRow("lba", hex(uint32(s), true))

proc displayPartitionType*(t: PartitionTypes) =
  displayTableSeperater()
  displayTableRow("partition type", hex(uint8(t), true))

proc displaySectorCount*(c: uint32) =
  displayTableSeperater()
  displayTableRow("sector count", hex(c, true))

proc displayPartionTable*(t: PartitionTable, headerStr: string) =
  displayTableHeader(headerStr)
  displayTableSeperater()
  displayPartitionBootFlag(t.bootFlag)
  displaySectorCHS(t.firstSectorCHS, "first sector (CHS)")
  displayPartitionType(t.partitionType)
  displaySectorCHS(t.lastSectorCHS, "last sector (CHS)")
  displaySectorLBA(t.firstSectorLBA, "first sector (LBA)")
  displaySectorCount(t.sectorCount)

proc displayBootSignature*(s: uint16) =
  displayTableSeperater()
  displayTableRow("boot signature", hex(s, true))

proc displayMasterBootRecord*(r: MasterBootRecord): void =
  displayPartionTable(r.partitionTable1, "partition table 1")
  displayPartionTable(r.partitionTable2, "partition table 2")
  displayPartionTable(r.partitionTable3, "partition table 3")
  displayPartionTable(r.partitionTable4, "partition table 4")
  displayBootSignature(r.bootSignature)