///n/*LOCAL*/ draw_text(x,y,text)
///same as /*LOCAL*/ draw_text but sends sprite to connected clients as well.

/*LOCAL*/ draw_text(argument0,argument1,argument2)

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 5)
    
    //x
    buffer_write(gx_buff, buffer_s16, round(argument0 - view_xview[0]))
    
    //y
    buffer_write(gx_buff, buffer_s16, round(argument1 - view_yview[0]))
    
    buffer_write(gx_buff, buffer_string, string(argument2))
  }
}
