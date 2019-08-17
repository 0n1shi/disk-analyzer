import tables, strutils

import sector, partition

const BootStrapCodeSize* = 446
type BootStrapCode* = array[BootStrapCodeSize, uint8]
type BootSignature* = array[2, uint8]

type MasterBootRecord* {.packed.} = object
    code*: BootStrapCode
    partitionTable1*: PartitionTable
    partitionTable2*: PartitionTable
    partitionTable3*: PartitionTable
    partitionTable4*: PartitionTable
    bootSignature*: BootSignature