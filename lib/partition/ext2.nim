import strutils, tables

type EXT2_OS = enum
  Linux       = 0
  GNU_Hurd    = 1
  MASIX       = 2
  FreeBSD     = 3
  WindowsLite = 4

type RevisionLevels = enum
  Old     = 0
  Dynamic = 1

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

type Ext2GroupDescriptor* {.packed.} = object
  blocksBitmapBlock*    : uint32
  inodesBitmapBlock*    : uint32
  inodesTableBlock*     : uint32
  freeBlocksCount*      : uint16
  freeInodesCount*      : uint16
  usedDirectoriesCount* : uint16
  padding*              : uint16
  reserved*             : array[3, uint32]
const Ext2GroupDescriptorSize* = 32

type BlockBitMap* = seq[uint8] # 0: Free/Available, 1: Used
type InodeBitMap* = seq[uint8]

type PointersToBlocks* = array[15, uint32]

type Ext2Inode* {.packed.} = object
  fileMode*           : uint16
  uid*                : uint16 # low 16 bit of owner id
  sizeInBytes*        : uint32
  accessTime*         : uint32
  creationTime*       : uint32
  modificationTime*   : uint32
  deletionTime*       : uint32
  gid*                : uint16 # low 16 bit of group id
  linksCount*         : uint16
  blocksCount*        : uint32
  fileFlags*          : uint32
  reserved*           : uint32 # OS dependent
  pointersToBlocks*   : PointersToBlocks
  fileVersion*        : uint32
  fileAcl*            : uint32
  DirectoryAcl*       : uint32
  fragmentAddress*    : uint32
  fragmentNumber*     : uint8 # OS dependent
  fragmentSize*       : uint8 # OS dependent
  padding*            : uint16 # OS dependent
  uidHigh*            : uint16 # OS dependent
  gidHigh*            : uint16 # OS dependent
  reserved2*          : uint32 # OS dependent
let Ext2InodeSize* = sizeof(Ext2Inode)

const
  EXT2_BAD_INO          = 1 # bad blocks inode
  EXT2_ROOT_INO         = 2 # root directory inode
  EXT2_ACL_IDX_INO      = 3 # ACL index inode (deprecated?)
  EXT2_ACL_DATA_INO     = 4 # ACL data inode (deprecated?)
  EXT2_BOOT_LOADER_INO  = 5 # boot loader inode
  EXT2_UNDEL_DIR_INO    = 6 # undelete directory inode

# values for Ext2Inode.fileMode
const
  # -- file format --
  EXT2_S_IFSOCK* = 0xC000  # socket
  EXT2_S_IFLNK*  = 0xA000  # symbolic link
  EXT2_S_IFREG*  = 0x8000  # regular file
  EXT2_S_IFBLK*  = 0x6000  # block device
  EXT2_S_IFDIR*  = 0x4000  # directory
  EXT2_S_IFCHR*  = 0x2000  # character device
  EXT2_S_IFIFO*  = 0x1000  # fifo
  # -- process execution user/group override --
  EXT2_S_ISUID*  = 0x0800  # Set process User ID
  EXT2_S_ISGID*  = 0x0400  # Set process Group ID
  EXT2_S_ISVTX*  = 0x0200  # sticky bit
  # -- access rights --
  EXT2_S_IRUSR*  = 0x0100  # user read
  EXT2_S_IWUSR*  = 0x0080  # user write
  EXT2_S_IXUSR*  = 0x0040  # user execute
  EXT2_S_IRGRP*  = 0x0020  # group read
  EXT2_S_IWGRP*  = 0x0010  # group write
  EXT2_S_IXGRP*  = 0x0008  # group execute
  EXT2_S_IROTH*  = 0x0004  # others read
  EXT2_S_IWOTH*  = 0x0002  # others write
  EXT2_S_IXOTH*  = 0x0001  # others execute
  fileModeTable* = {
    # -- file format --
    0xC000 : "socket",
    0xA000 : "symbolic link",
    0x8000 : "regular file",
    0x6000 : "block device",
    0x4000 : "directory",
    0x2000 : "character device",
    0x1000 : "fifo",
    # -- process execution user/group override --
    0x0800 : "Set process User ID",
    0x0400 : "Set process Group ID",
    0x0200 : "sticky bit",
    # -- access rights --
    0x0100 : "user read",
    0x0080 : "user write",
    0x0040 : "user execute",
    0x0020 : "group read",
    0x0010 : "group write",
    0x0008 : "group execute",
    0x0004 : "others read",
    0x0002 : "others write",
  }

# values for Ext2Inode.fileFlags
const
  EXT2_SECRM_FL         = 0x00000001  # secure deletion
  EXT2_UNRM_FL          = 0x00000002  # record for undelete
  EXT2_COMPR_FL         = 0x00000004  # compressed file
  EXT2_SYNC_FL          = 0x00000008  # synchronous updates
  EXT2_IMMUTABLE_FL     = 0x00000010  # immutable file
  EXT2_APPEND_FL        = 0x00000020  # append only
  EXT2_NODUMP_FL        = 0x00000040  # do not dump/delete file
  EXT2_NOATIME_FL       = 0x00000080  # do not update .i_atime
  # -- Reserved for compression usage --
  EXT2_DIRTY_FL         = 0x00000100  # Dirty (modified)
  EXT2_COMPRBLK_FL      = 0x00000200  # compressed blocks
  EXT2_NOCOMPR_FL       = 0x00000400  # access raw compressed data
  EXT2_ECOMPR_FL        = 0x00000800  # compression error
  # -- End of compression flags --
  EXT2_BTREE_FL         = 0x00001000  # b-tree format directory
  EXT2_INDEX_FL         = 0x00001000  # hash indexed directory
  EXT2_IMAGIC_FL        = 0x00002000  # AFS directory
  EXT3_JOURNAL_DATA_FL  = 0x00004000  # journal file data
  EXT2_RESERVED_FL      = 0x80000000  # reserved for ext2 library

const inodeTableBlockCount* = 214