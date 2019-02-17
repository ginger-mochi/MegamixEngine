///ndraw_rectangle(x1,y1,x2,y2,rectangle)
///same as draw_rectangle but sends sprite to connected clients as well.

/*LOCAL*/ draw_rectangle(argument0,argument1,argument2,argument3,argument4)

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 10)
    
    //x1
    buffer_write(gx_buff, buffer_s16, round(argument0 - view_xview[0]))
    
    //y1
    buffer_write(gx_buff, buffer_s16, round(argument1 - view_yview[0]))
    
    //x2
    buffer_write(gx_buff, buffer_s16, round(argument2 - view_xview[0]))
    
    //y2
    buffer_write(gx_buff, buffer_s16, round(argument3 - view_yview[0]))
    
    //outline
    buffer_write(gx_buff, buffer_bool, argument4 != 0)
  }
}
