import os, strformat

import mbr
import ../../utils

proc displaySectorCHS*(s: SectorCHS): void =
  echo fmt("{hex(s.head, true):>10}")

#proc displayMasterBootRecord(r: MasterBootRecord): void =

