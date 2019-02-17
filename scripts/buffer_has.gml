/// buffer_has(buffer, bytes)
/// returns true if the given number of bytes can be read from the given buffer

return buffer_get_size(argument0) - buffer_tell(argument0) >= argument1;