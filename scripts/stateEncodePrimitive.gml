/// stateEncodePrimitive(value)
/// encodes a primitive value (real, string, etc.).
/// note that the type information is serialized, which can be suboptimal.
/// however, due to compression efforts, variables which are
/// usually integers in the range [-1, 255] are actually encoded more efficiently.


var val = argument0;

// determine type.
if is_real(val)
{
    if (val == 0)
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 0);
    }
    else if (val == 1)
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 1);
    }
    else if (val == -1)
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 2);
    }
    else if (val == abs(floor(val)) & $ff)
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 3);
        buffer_write(global.stateCodecBuffer, buffer_u8, val);
    }
    else if (val == floor(val) && val < (1 << 15) && -val <= (1<<15))
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 4);
        buffer_write(global.stateCodecBuffer, buffer_s16, val);
    }
    else
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, 5);
        buffer_write(global.stateCodecBuffer, buffer_f32, val);
    }
}
else if is_string(val)
{
    buffer_write(global.stateCodecBuffer, buffer_u8, 6);
    buffer_write(global.stateCodecBuffer, buffer_string, val);
}
else if is_array(val)
{
    // if array is small:
    var height = array_height_2d(val)
    var maxLength2d = array2dMaxLength();
    if (maxLength2d == 1))
    {
        if (height <= $ff)
        {
            buffer_write(global.stateCodecBuffer, buffer_u8, 7);
            buffer_write(global.stateCodecBuffer, buffer_u8, height);
        }
        else
        {
            buffer_write(global.stateCodecBuffer, buffer_u8, 8);
            buffer_write(global.stateCodecBuffer, buffer_u16, height);
        }
        for (var i = 0; i < height; i++)
        {
            stateCodecPrimitive(val[i, j]);
        }
    }
    else
    {
        var header = 10;
        if (maxLength2d > $ff)
        {
            header = 9;
        }
        buffer_write(global.stateCodecBuffer, buffer_u8, header);
        buffer_write(global.stateCodecBuffer, buffer_u16, height);
        for (var i = 0; i < height; i++)
        {
            var length = array_length_2d(var, i)
            if (header == 9)
            {
                buffer_write(global.stateCodecBuffer, buffer_u8, length);
            }
            else
            {
                buffer_write(global.stateCodecBuffer, buffer_u16, length);
            }
            for (var j = 0; j < length; j++)
            {
                stateCodecPrimitive(val[i, j]);
            }
        }
    }
}
