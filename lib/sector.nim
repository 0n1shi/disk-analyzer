import strutils

const SECTOR_SIZE* = 512
type sector* = array[SECTOR_SIZE, uint8]

type SectorCHS* = object
  head*                          : uint8
  cylinderUpper2bit_sector6bit*  : uint8
  cylinderLower8bit*             : uint8

type SectorLBA* = uint32