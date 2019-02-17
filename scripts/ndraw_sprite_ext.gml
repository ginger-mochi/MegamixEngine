///n/*LOCAL*/ ndraw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, colour, alpha)
///same as /*LOCAL*/ ndraw_sprite_ext but sends sprite to connected clients as well.

/*LOCAL*/ ndraw_sprite_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 2)
    
    //sprite
    buffer_write(gx_buff, buffer_s16, enc_spr(floor(argument0)))
    
    //subimage
    buffer_write(gx_buff, buffer_u8, round(argument1))
    
    //x
    buffer_write(gx_buff, buffer_s16, round(argument2 - view_xview[0]))
    
    //y
    buffer_write(gx_buff, buffer_s16, round(argument3 - view_yview[0]))
    
    buffer_write(gx_buff, buffer_f32, argument4);
    buffer_write(gx_buff, buffer_f32, argument5);
    buffer_write(gx_buff, buffer_f32, argument6);
    buffer_write(gx_buff, buffer_u32, argument7);
    buffer_write(gx_buff, buffer_f32, argument8);
  }
}