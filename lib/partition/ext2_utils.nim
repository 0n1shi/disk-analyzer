import ext2

proc toGroupDescriptor*(data: seq[uint8]): Ext2GroupDescriptor =
  var buffer : array[Ext2GroupDescriptorSize, uint8]
  for i in 0..<Ext2GroupDescriptorSize:
    buffer[i] = data[i]
  return cast[Ext2GroupDescriptor](buffer)

proc displayFileMode*(mode: int): string =
  var message = ""
  for k, v in fileModeTable:
    let modeValue = v[0]
    let msg = v[1]
    if (mode and modeValue) > 0:
      if k == 0:
        message = msg
      else:
        message = message & " / " & msg
  return message

proc isTheMode*(mode: int): bool =
  return (mode and EXT2_S_IFREG) > 0