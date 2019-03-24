/// stateCodecIDEncode(id)
/// encodes an id into an unswizzled id

var _id = argument0;
var encode = 0;
assert(_id == floor(_id), "attempting to encode non-integer id!")
if (_id < 0)
{
    // special values
    assert(_id >= -4, "attempting to encode unknown negative id");
    encode = _id + $10000;
}
else if (object_exists(_id))
{
    assert(_id < global.lastObject, "attempted to encode custom object");
    encode = _id - global.firstObject;
}
else
{
    if (!instance_exists(_id))
    {
        // encode destroyed instances as noone.
        encode = $10000 + noone;
    }
    else
    {
        var uid = ds_map_find_value(global.stateCodecIDToUnswizzled, _id);
        assert(!is_undefined(uid), "no mapping for id!");
        encode = uid + global.lastObject;
    }
}

// consider using buffer_f32 instead if number of instances + objects exceeds $fffb
if (!is_undefined(global.stateCodecBuffer))
{
    buffer_write(global.stateCodecBuffer, buffer_u16, encode);
}
return encode

