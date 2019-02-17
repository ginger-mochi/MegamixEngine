///n/*LOCAL*/ draw_sprite(sprite, subimg, x, y)

/*LOCAL*/ draw_sprite(argument0,argument1,argument2,argument3);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
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