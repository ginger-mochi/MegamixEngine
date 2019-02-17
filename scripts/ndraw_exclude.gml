/// ndraw_exclude(player_id)
/// asks the client to not draw the next command if they have a player with the given id
/// used to render local mega man specially

with objNet {
  if srv_isServing {
    //TODO: skip if bounds off-screen
  
    //draw command
    buffer_write(gx_buff, buffer_s8, 11)
    buffer_write(gx_buff, buffer_u16, floor(max(0,argument0)));
  }
}
