/// stateCodecPrimitiveDecode()
/// encodes/decodes a primitive value (real, string, etc.).
/// note that the type information is serialized, which can be suboptimal.
/// however, due to compression efforts, variables which are
/// usually integers in the range [-1, 255] are actually encoded more efficiently.

var header = buffer_read(global.stateCodecBuffer, buffer_u8);
switch (header)
{
    case 0:
        return 0;
    case 1:
        return 1;
    case 2:
        return -1;
    case 3:
        return buffer_read(global.stateCodecBuffer, buffer_u8);
    case 4:
        return buffer_read(global.stateCodecBuffer, buffer_s16);
    case 5:
        return buffer_read(global.stateCodecBuffer, buffer_f32);
    case 6:
        return buffer_read(global.stateCodecBuffer, buffer_string);
    default: {
        // arrays
        var height;
        var is1d = true;
        var hasLongRows2D = false;
        switch (header)
        {
            case 7:
                height = buffer_read(global.stateCodecBuffer, buffer_u8);
                break;
            case 8:
                height = buffer_read(global.stateCodecBuffer, buffer_u16);
                break;
            case 9:
                hasLongRows2D = true;
                // fallthrough //
            case 10:
                height = buffer_read(global.stateCodecBuffer, buffer_u16);
                is1d = false;
                break;
        }
        var retv;
        if (is1d)
        {
            // 1d array
            
            // initialize array
            retv[height - 1] = 0;
            for (var i = 0; i < height; i++)
            {
                retv[i] = stateCodecPrimitive(0);
            }
            return retv;
        }
        else
        {
            // 2d array 
            
            // initialize array
            retv[height - 1, 0] = 0;
            for (var i = 0; i < height; i++)
            {
                var length;
                if (hasLongRows2D)
                {
                    length = buffer_read(global.stateCodecBuffer, buffer_u16);
                }
                else
                {
                    length = buffer_read(global.stateCodecBuffer, buffer_u8);
                }
                // initialize row
                retv[i, length - 1] = 0;
                for (var j = 0; j < length; j++)
                {
                    retv[i, j] = stateCodecPrimitive(0);
                }
            }
            return retv;
        }
    }
}
