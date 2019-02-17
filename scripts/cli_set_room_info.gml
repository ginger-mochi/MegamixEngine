///cli_set_room_info(tile_buffer)
///sets tiles as determined by server as well as room information

var tb = argument0;

if room != rmNetClient
  exit;

// clear all existing tiles:
cli_clear_tiles_recent();

// set room info

room_width = buffer_read(tb, buffer_s32);
room_height = buffer_read(tb, buffer_s32);
background_color = buffer_read(tb, buffer_s32)

// read backgrounds
for (var i=0;i<8;i++) {
    background_visible[i] = buffer_read(tb, buffer_bool);
    background_index[i] = dec_bg(buffer_read(tb, buffer_s16));
}