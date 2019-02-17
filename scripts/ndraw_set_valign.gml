///nndraw_set_halign(align)
///same as ndraw_set_halign but sends sprite to connected clients as well.

/*LOCAL*/ ndraw_set_valign(argument0);

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 9)
    
    //colour
    buffer_write(gx_buff, buffer_s8, argument0);
  }
}
