/// stateCodecIDDecode()
/// returns an id from an encoded unswizzled id

var uid = buffer_read(global.stateCodecUnswizzleToID, buffer_u16);
if (uid >= $fffc)
{
    // special values
    return uid - $10000;
}
else if (object_exists(uid))
{
    return global.firstObject + uid;
}
else
{
    var uid = ds_map_find_value(global.stateCodecUnswizzledToID, uid);
    assert(!is_undefined(uid), "no mapping for unswizzled id!");
    return uid;
}
