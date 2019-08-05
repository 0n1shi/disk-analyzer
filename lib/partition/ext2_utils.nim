import ext2

proc toGroupDescriptor*(data: seq[uint8]): Ext2GroupDescriptor =
  var buffer : array[Ext2GroupDescriptorSize, uint8]
  for i in 0..<Ext2GroupDescriptorSize:
    buffer[i] = data[i]
  return cast[Ext2GroupDescriptor](buffer)