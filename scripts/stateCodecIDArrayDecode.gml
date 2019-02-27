/// stateCodecIDArrayDecode()
/// decodes an unswizzled id array into an id array

// decode array and then map to swizzled id.

var uidarr = stateCodecPrimitiveDecode();

if (!is_array(uidarr))
{
    return uidarr;
}

var height = array_height_2d(uidarr);

for (var i = 0; i < height; i++)
{
    var length = array_length_2d(uidarr, i);
    for (var j = 0; j < length; j++)
    {
        uidarr[i, j] = stateCodecIDDecode(uidarr[i, j]);
    }
}

return uidarr;
