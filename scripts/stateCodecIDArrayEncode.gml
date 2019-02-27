/// stateCodecIDArrayEncode(idarray)
/// encodes an id array into an unswizzled id array


// map array elements to unswizzled ID and then encode.
var idarr = argument0;
var uidarr;

var buffer = global.stateCodecBuffer;
global.stateCodecBuffer = undefined;

var height = array_height_2d(idarr);

for (var i = 0; i < height; i++)
{
    var length = array_length_2d(idarr, i);
    for (var j = 0; j < length; j++)
    {
        uidarr[i, j] = stateCodecIDEncode(idarr[i, j]);
    }
}

global.stateCodecBuffer = buffer;

stateCodecPrimitiveEncode(uidarr);
