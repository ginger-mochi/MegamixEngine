/// stateCodexInstance()
// encodes/decodes the current instance into a buffer.

// bitstring encodings (basic instance data and data comression flags).
var complexImageEncoding;
var hasSprite = sprite_index != -1;
var complexMotionEncoding;
var hasAlarms = false;

// TODO: alarms are rare enough that they could be made object-specific.
for (var i = 0; i < 12; i++)
{
    if (alarm[i] != 0)
    {
        hasAlarms = true;
        break;
    }
}

// alarms and masks are both rare, so we combine their flags (in an attempt to minimize entropy).
var hasMaskOrAlarms = mask_index != -1 || hasAlarms;

if (global.stateCodecEncode)
{
    complexImageEncoding = (image_alpha != 1 || image_angle != 0 || image_blend != c_white || abs(image_xscale) != 1 || abs(image_yscale) != 1);
    complexMotionEncoding = solid || hspeed != 0 || vspeed != 0 || friction != 0 || gravity != 0
    var bitString = complexMotionEncoding | (!!visible << 1) | (!!persistent << 2) | ((image_xscale == 1) << 3)
        | ((image_yscale == 1) << 4) | (complexImageEncoding << 5)
        | (hasSprite << 6) | (hasMaskOrAlarms << 7);
    buffer_write(global.stateCodecBuffer, buffer_u8, bitString);
}
else
{
    var bitString = buffer_read(global.stateCodecBuffer, buffer_u8);
    complexMotionEncoding = !!(bitString & $1);
    visible = !!(bitString & $2);
    persistent = !!(bitString & $4);
    image_xscale = !!(bitString & $8);
    image_xscale = image_xscale * 2 - 1;
    image_yscale = !!(bitString & $10);
    image_yscale = image_yscale * 2 - 1;
    complexImageEncoding = !!(bitString & $20);
    hasSprite = !!(bitString & $40);
    hasMaskOrAlarms = !!(bitString & $80);
}

// most instance data.
if (global.stateCodecEncode)
{
    buffer_write(global.stateCodecBuffer, buffer_f32, x);
    buffer_write(global.stateCodecBuffer, buffer_f32, y);
    if (hasSprite)
    {
        buffer_write(global.stateCodecBuffer, buffer_u16, sprite_index - global.firstSprite);
        var imageNumber = sprite_get_number(sprite_index) > 1;
        if (imageNumber > 1)
        {
            buffer_write(global.stateCodecBuffer, buffer_f32, image_index);
            print(object_get_name(object_index) + string(image_index));
        }
    }
    if (hasMaskOrAlarms)
    {
        // mask:
        if (mask_index == -1)
        {
            buffer_write(global.stateCodecBuffer, buffer_u16, $ffff);
        }
        else
        {
            buffer_write(global.stateCodecBuffer, buffer_u16, mask_index - global.firstSprite);
        }
        
        // alarms:
        for (var i = 0; i < 12; i++)
        {
            buffer_write(global.stateCodecBuffer, buffer_f32, alarm[i]);
        }
    }
    buffer_write(global.stateCodecBuffer, buffer_f32, image_speed);
    if (complexImageEncoding)
    {
        buffer_write(global.stateCodecBuffer, buffer_f32, image_alpha);
        buffer_write(global.stateCodecBuffer, buffer_f32, image_angle);
        buffer_write(global.stateCodecBuffer, buffer_f32, image_blend);
        buffer_write(global.stateCodecBuffer, buffer_f32, image_xscale);
        buffer_write(global.stateCodecBuffer, buffer_f32, image_yscale);
    }
    if (complexMotionEncoding)
    {
        buffer_write(global.stateCodecBuffer, buffer_u8, solid);
        buffer_write(global.stateCodecBuffer, buffer_f32, hspeed);
        buffer_write(global.stateCodecBuffer, buffer_f32, vspeed);
        buffer_write(global.stateCodecBuffer, buffer_f32, friction);
        buffer_write(global.stateCodecBuffer, buffer_f32, gravity);
        buffer_write(global.stateCodecBuffer, buffer_f32, gravity_direction);
    }
    // minimum: 13 bytes. maximum: 110 bytes.
    // expected median: 19 bytes.
    
    // minimum could possibly be reduced by not encoding x,y for objects without a sprite
    // and located at (0, 0) (using hasSprite flag in bitString.)
}
else
{
    x = buffer_read(global.stateCodecBuffer, buffer_f32);
    y = buffer_read(global.stateCodecBuffer, buffer_f32);
    
    // read sprite
    if (hasSprite)
    {
        sprite_index = buffer_read(global.stateCodecBuffer, buffer_u16) + global.firstSprite;
        var imageNumber = sprite_get_number(sprite_index) > 1;
        if (imageNumber > 1)
        {
            image_index = buffer_read(global.stateCodecBuffer, buffer_f32);
        }
        else
        {
            image_index = 0;
        }
    }
    else
    {
        sprite_index = -1;
    }
    
    if (hasMaskOrAlarms)
    {
        // read mask
        var in = buffer_read(global.stateCodecBuffer, buffer_u16);
        if (in == $ffff)
        {
            mask_index = -1;
        }
        else
        {
            mask_index = in + global.firstSprite;
        }
        
        // read alarms
        for (var i = 0; i < 12; i++)
        {
            alarm[i] = buffer_read(global.stateCodecBuffer, buffer_f32);
        }
    }
    else
    {
        mask_index = -1;
    }
    
    // image data
    image_speed = buffer_read(global.stateCodecBuffer, buffer_f32);
    if (complexImageEncoding)
    {
        image_alpha  = buffer_read(global.stateCodecBuffer, buffer_f32);
        image_angle  = buffer_read(global.stateCodecBuffer, buffer_f32);
        image_blend  = buffer_read(global.stateCodecBuffer, buffer_f32);
        image_xscale = buffer_read(global.stateCodecBuffer, buffer_f32);
        image_yscale = buffer_read(global.stateCodecBuffer, buffer_f32);
    }
    else
    {
        image_alpha = 1;
        image_angle = 0;
        image_blend = c_white;
        // xscale and yscale set by bitstring.
    }
    
    // motion encoding
    if (complexMotionEncoding)
    {
        solid    = !!buffer_read(global.stateCodecBuffer, buffer_u8);
        hspeed   =   buffer_read(global.stateCodecBuffer, buffer_f32);
        vspeed   =   buffer_read(global.stateCodecBuffer, buffer_f32);
        friction =   buffer_read(global.stateCodecBuffer, buffer_f32);
        gravity  =   buffer_read(global.stateCodecBuffer, buffer_f32);
        gravity_direction = buffer_read(global.stateCodecBuffer, buffer_f32);
    }
    else
    {
        solid = false;
        hspeed = 0;
        vspeed = 0;
        friction = 0;
        gravity = 0;
    }
}
