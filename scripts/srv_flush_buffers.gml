/// srv_flush_buffers
// flushes all buffers, sending them to clients right away.

// send view coords
buffer_write(cmd_buff, buffer_s8, 104)
buffer_write(cmd_buff, buffer_s32, view_xview[0])
buffer_write(cmd_buff, buffer_s32, view_yview[0])
   
//terminate command and graphics buffers
buffer_write(gx_buff, buffer_s8, -1)
buffer_write(cmd_buff, buffer_s8, -1)

// broadcast graphics and commands to all connected clients:
if buffer_tell(gx_buff) > 2
    server_broadcast_udp(gx_buff, buffer_tell(gx_buff));
server_broadcast_udp(cmd_buff, buffer_tell(cmd_buff));

// reset buffers
buffer_seek(gx_buff,buffer_seek_start,0);
buffer_write(gx_buff,buffer_u8,PTYPE.gfx)

buffer_seek(cmd_buff,buffer_seek_start,0);
buffer_write(cmd_buff,buffer_u8,PTYPE.cmd)
