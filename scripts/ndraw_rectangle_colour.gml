///ndraw_rectangle_colour(x1,y1,x2,y2,c1,c2,c3,c4,rectangle)
///same as draw_rectangle but sends sprite to connected clients as well.

/*LOCAL*/ draw_rectangle_colour(argument0,argument1,argument2,argument3,argument4,argument5, argument6,argument6,argument8)

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //opcode
    buffer_write(gx_buff, buffer_s8, 15)
    
    //x1
    buffer_write(gx_buff, buffer_s16, round(argument0 - view_xview[0]))
    
    //y1
    buffer_write(gx_buff, buffer_s16, round(argument1 - view_yview[0]))
    
    //x2
    buffer_write(gx_buff, buffer_s16, round(argument2 - view_xview[0]))
    
    //y2
    buffer_write(gx_buff, buffer_s16, round(argument3 - view_yview[0]))
    
    //c1
    buffer_write(gx_buff, buffer_u32, argument4);
    
    //c2
    buffer_write(gx_buff, buffer_u32, argument5);
    
    //c3
    buffer_write(gx_buff, buffer_u32, argument6);
    
    //c4
    buffer_write(gx_buff, buffer_u32, argument7);
    
    //outline
    buffer_write(gx_buff, buffer_bool, !! argument8)
  }
}
