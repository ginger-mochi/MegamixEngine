///n/*LOCAL*/ draw_sprite(sprite, subimg, x, y)

/*LOCAL*/ draw_sprite(argument0,argument1,argument2,argument3);

with objNet {
  if srv_isServing {
<<<<<<< HEAD
    // skip if outside view
    var xoffset = sprite_get_xoffset(argument0);
    var yoffset = sprite_get_yoffset(argument0);
    if (argument2 - xoffset > view_xview[0] + view_wview[0]) exit;
    if (argument3 - yoffset > view_yview[0] + view_hview[0]) exit;
    
    var width = sprite_get_width(argument0);
    var height = sprite_get_height(argument0);
    if (argument2 + width  - xoffset < view_xview[0]) exit;
    if (argument3 + height - yoffset < view_yview[0]) exit;
=======
    //TODO: skip if bounds off-screen
>>>>>>> parent of b5d88381... ndraw_text fixes
  
    //draw command
    buffer_write(gx_buff, buffer_s8, 1)
    
    //sprite
    buffer_write(gx_buff, buffer_s16, enc_spr(floor(argument0)))
    
    //subimage
    buffer_write(gx_buff, buffer_u8, round(argument1))
    
    //x
    buffer_write(gx_buff, buffer_s16, round(argument2 - view_xview[0]))
    
    //y
    buffer_write(gx_buff, buffer_s16, round(argument3 - view_yview[0]))
  }
}
