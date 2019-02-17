///n/*LOCAL*/ draw_set_halign(align)
///same as /*LOCAL*/ draw_set_halign but sends sprite to connected clients as well.

/*LOCAL*/ draw_set_halign(argument0);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 8)
    
    //colour
    buffer_write(gx_buff, buffer_s8, argument0);
  }
}