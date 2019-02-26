/// stateCodecDSEncode(datastructure, dsType)
/// encode the given datastructure.

var val = argument0, dsType = argument1;

// TODO -- actually encode the datastructure, dummy!
buffer_write(global.stateCodecBuffer, buffer_f32, val);
