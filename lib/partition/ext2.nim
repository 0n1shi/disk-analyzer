import strutils

type EXT2_OS = enum
  Linux       = 0
  GNU_Hurd    = 1
  MASIX       = 2
  FreeBSD     = 3
  WindowsLite = 4

type RevisionLevels = enum
  Old     = 0
  Dynamic = 1

const OldInodeSize = 128

type BootBlock* = array[0x400, char]

type Ext2SuperBlock* {.packed.} = object
  inodeCount*                       : uint32
  blockCount*                       : uint32
  reservedBlockCount*               : uint32
  freeBlockCount*                   : uint32
  freeInodeCount*                   : uint32
  firstDataBlock*                   : uint32
  blockSize*                        : uint32
  flagmentSize*                     : uint32
  blocksPerGroup*                   : uint32
  fragmentsPerGroup*                : uint32
  inodesPerGroup*                   : uint32
  mountTime*                        : uint32
  writeTime*                        : uint32
  mountCount*                       : uint16
  maxMountCount*                    : uint16
  magicSignature*                   : uint16 
  fileSystemState*                  : uint16
  errors*                           : uint16
  minorRevisionLevel*               : uint16
  lastCheckTime*                    : uint32
  checkInterval*                    : uint32
  os*                               : uint32
  revisionLevel*                    : uint32
  defaultUIDForReservedBlocks*      : uint16
  defaultGIDForReservedBlocks*      : uint16
  
  firstNonReservedInode*            : uint32
  sizeOfInodeStructure*             : uint16
  blockGroupOfThisSuperBlock*       : uint16
  compatibleFeatureSet*             : uint32
  incompatibleFeatureSet*           : uint32
  readonlyCompatibleFeatureSet*     : uint32
  uuidForVolume*                    : array[16, uint8]
  volumeName*                       : array[16, char]
  lastMountedDirectory*             : array[64, char]
  algorithmUsageBitmap*             : uint32
  blocksToPreallocate*              : uint8
  blocksToPreallocateForDirectory*  : uint8
  padding*                          : uint16

  uuidOfJournalSuperBlock*          : array[16, uint8]
  inodeNumberOfJournalFile*         : uint32
  deviceNumberOfJournal*            : uint32
  startIndexOfInodeListToDelete*    : uint32
  hTreeHashSeed*                    : array[4, uint32]
  defaultHashVersion*               : uint8
  reservedCharPagging*              : uint8
  reservedWordPadding*              : uint16
  defaultMountOptions*              : uint32
  firstMetaBlockGroup*              : uint32
  reservedPadding*                  : array[190, uint32]

