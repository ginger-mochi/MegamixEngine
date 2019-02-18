///ndraw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, colour, alpha)
///same as draw_sprite_ext but sends sprite to connected clients as well.

var txscale = argument4;
var tyscale = argument5;

/*LOCAL*/ draw_sprite_ext(argument0,argument1,argument2,argument3,txscale,tyscale,argument6,argument7,argument8);

with objNet {
  if srv_isServing {
    // cull if out of view
    if (txscale == 0 || tyscale == 0) exit;
    var xoffset = sprite_get_xoffset(argument0);
    var yoffset = sprite_get_yoffset(argument0);
    var swidth = sprite_get_width(argument0);
    var sheight = sprite_get_height(argument0);
    if (argument2 + (swidth + abs(xoffset)) * abs(txscale) > view_xview[0] + view_wview[0]) exit;
    if (argument3 + (sheight + abs(yoffset)) * abs(tyscale) > view_yview[0] + view_hview[0]) exit;

    if (argument2 + (abs(xoffset) + swidth) * abs(txscale) < view_xview[0]) exit;
    if (argument3 + (abs(yoffset) + sheight) * abs(tyscale) < view_yview[0]) exit;
  
    // see if it's possible to send compressed version
    var basic = false;
    if (x - view_xview[0] >= 0 && x - view_xview[0] < 255
        && y - view_yview[0] >= -16 && y - view_yview[0] < 255 - 16
        && argument6 == 0 && argument7 == c_white && argument8 == 1
        && sign(txscale) == txscale && sign(tyscale) == tyscale
        && argument1 == round(argument1) % 64)
    {
        // compressed version.
        // The majority of draw requests are sprite_ext, because that's the default
        // entity draw, so it's important to compress where possible.
        
        //opcode
        buffer_write(gx_buff, buffer_s8, 16);
        
        //sprite
        buffer_write(gx_buff, buffer_s16, enc_spr(floor(argument0)));
        
        //subimage, xscale, yscale
        // (6 bits for subimage, 1 bit each for xscale and yscale)
        buffer_write(gx_buff, buffer_u8,
              round(argument1) << 2 
            | (txscale == -1)  << 1 
            | (tyscale == -1));
        
        // x, y (1 byte each)
        buffer_write(gx_buff, buffer_u8, round(x - view_xview[0]));
        buffer_write(gx_buff, buffer_u8, round(y - view_yview[0] + 16));
        
        // 6 bytes.
    }
    else
    {
        // complicated version
        
        //opcode
        buffer_write(gx_buff, buffer_s8, 2);
        
        //sprite
        buffer_write(gx_buff, buffer_s16, enc_spr(floor(argument0)));
        
        //subimage
        buffer_write(gx_buff, buffer_u8, round(argument1));
        
        //x
        buffer_write(gx_buff, buffer_s16, round(argument2 - view_xview[0]));
        
        //y
        buffer_write(gx_buff, buffer_s16, round(argument3 - view_yview[0]));
        
        //xscale
        buffer_write(gx_buff, buffer_f32, argument4);
        
        //yscale
        buffer_write(gx_buff, buffer_f32, argument5);
        
        //rot
        buffer_write(gx_buff, buffer_f32, argument6);
        
        //color
        buffer_write(gx_buff, buffer_u32, argument7);
        
        //alpha
        buffer_write(gx_buff, buffer_u8, round(argument8 * 255));
        
        // 25 bytes.
    }
  }
}
