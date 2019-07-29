import ../lib/partition/ext2
import ../lib/mbr/mbr

var ext2SuperBlock: Ext2SuperBlock
var mbRecord: MasterBootRecord

echo sizeof(mbRecord)