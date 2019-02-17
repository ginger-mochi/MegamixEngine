///n/*LOCAL*/ draw_sprite_part_ext(sprite, subimg, left, top, width, height x, y, xscale, yscale, colour, alpha)
///same as /*LOCAL*/ draw_sprite_part_ext but sends sprite to connected clients as well.

/*LOCAL*/ draw_sprite_part_ext(argument0,argument1,argument2,argument3,argument4,argument5,argument6,argument7,argument8,argument9,argument10,argument11);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 4)
    
    //sprite
    buffer_write(gx_buff, buffer_s16, enc_spr(floor(argument0)))
    
    //subimage
    buffer_write(gx_buff, buffer_u8, round(argument1))
    
    //left
    buffer_write(gx_buff, buffer_u16, max(0,round(argument2)))
    
    //top
    buffer_write(gx_buff, buffer_u16, max(0,round(argument3)))
    
    //width
    buffer_write(gx_buff, buffer_u16, max(0,round(argument4)))
    
    //height
    buffer_write(gx_buff, buffer_u16, max(0,round(argument5)))
    
    //x
    buffer_write(gx_buff, buffer_s16, round(argument6 - view_xview[0]))
    
    //y
    buffer_write(gx_buff, buffer_s16, round(argument7 - view_yview[0]))
    
    buffer_write(gx_buff, buffer_f32, argument8);
    buffer_write(gx_buff, buffer_f32, argument9);
    buffer_write(gx_buff, buffer_u32, argument10);
    buffer_write(gx_buff, buffer_f32, argument11);
  }
}