/// stateCodecIDDecode([uid])
/// returns an id from an encoded unswizzled id

var uid;
if (argument_count == 0)
{
    uid = buffer_read(global.stateCodecBuffer, buffer_u16);
}
else
{
    uid = argument[0];
}

if (uid >= $fffc)
{
    // special values
    return uid - $10000;
}
else if (uid < (global.lastObject - global.firstObject))
{
    return global.firstObject + uid;
}
else
{
    uid = ds_map_find_value(global.stateCodecUnswizzledToID, uid - global.lastObject);
    assert(!is_undefined(uid), "no mapping for unswizzled id!");
    return uid;
}
