/// ncmd_tiles()
/// sends the room's tiles to the client

if !objNet.srv_isServing
    exit;

// rsetup room on client, including tiles
buffer_seek(tile_buff, buffer_seek_start, 0);
tile_buff_chunk_n = 0;
tile_buff_chunk[0] = 0;

buffer_write(tile_buff, buffer_s8, 99)

buffer_write(tile_buff, buffer_s32, room_width);
buffer_write(tile_buff, buffer_s32, room_height);
buffer_write(tile_buff, buffer_s32, background_color)

// write backgrounds
for (var i=0;i<8;i++) {
    buffer_write(tile_buff, buffer_bool, background_visible[i]);
    buffer_write(tile_buff, buffer_s16, enc_bg(background_index[i]))
}

// write tiles
buffer_write(tile_buff, buffer_s8, 100)

var tiles = tile_get_ids();

print("Sending tiles...")

var flush = 0;
for (var i=0;i< array_length_1d(tiles); i++) {
    // monitor buffer and chunk if it's getting too large:
    if buffer_tell(tile_buff) > 400*(tile_buff_chunk_n + 1) {
        buffer_write(tile_buff,buffer_s32,-1)
        tile_buff_chunk[++tile_buff_chunk_n] = buffer_tell(tile_buff);
        buffer_write(tile_buff, buffer_s8, 100);
        flush ++;
        print("Chunk no. " + string(flush));
    }
  
  var t = tiles[i]
    
  //background id
  buffer_write(tile_buff,buffer_s16,enc_bg(tile_get_background(t)))
  
  //depth
  buffer_write(tile_buff,buffer_f64,floor(tile_get_depth(t)))
  
  // dimensions
  buffer_write(tile_buff,buffer_u16,floor(tile_get_left(t)))
  buffer_write(tile_buff,buffer_u16,floor(tile_get_top(t)))
  buffer_write(tile_buff,buffer_u8,floor(tile_get_width(t)))
  buffer_write(tile_buff,buffer_u8,floor(tile_get_height(t)))
  
  // x,y
  buffer_write(tile_buff,buffer_u16,round(tile_get_x(t)/16))
  buffer_write(tile_buff,buffer_u16,round(tile_get_y(t)/16))
}

buffer_write(tile_buff,buffer_s32,-1)
tile_buff_chunk[++tile_buff_chunk_n] = buffer_tell(tile_buff);
