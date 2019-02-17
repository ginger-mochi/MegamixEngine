///n/*LOCAL*/ ndraw_set_color(col)
///same as /*LOCAL*/ ndraw_set_color but sends sprite to connected clients as well.

/*LOCAL*/ ndraw_set_color(argument0);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 6)
    
    //colour
    buffer_write(gx_buff, buffer_u32, argument0);
  }
}