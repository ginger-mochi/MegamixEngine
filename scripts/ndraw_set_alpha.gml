///nndraw_set_alpha(col)
///same as ndraw_set_alpha but sends sprite to connected clients as well.

/*LOCAL*/ draw_set_alpha(argument0);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 7)
    
    //colour
    buffer_write(gx_buff, buffer_f32, argument0);
  }
}
