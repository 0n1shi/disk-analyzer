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

const BLOCK_SIZE_BASE* = 0x400

type BootBlock* = array[BLOCK_SIZE_BASE, char]

type Ext2SuperBlock* {.packed.} = object
  inodesCount*                      : uint32
  blocksCount*                      : uint32
  reservedBlocksCount*              : uint32
  freeBlocksCount*                  : uint32
  freeInodesCount*                  : uint32
  firstDataBlock*                   : uint32
  blockSize*                        : uint32 # BLOCK_SIZE_BASE << x
  flagmentSize*                     : uint32 # BLOCK_SIZE_BASE << x
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

type 
  Ext2GroupDescriptor* {.packed.} = object
    blocksBitmapBlock*    : uint32
    inodesBitmapBlock*    : uint32
    inodesTableBlock*     : uint32
    freeBlocksCount*      : uint16
    freeInodesCount*      : uint16
    usedDirectoriesCount* : uint16
    padding*              : uint16
    reserved*             : array[3, uint32]
const Ext2GroupDescriptorSize* = 32

type BlockBitMap* = seq[uint8]

