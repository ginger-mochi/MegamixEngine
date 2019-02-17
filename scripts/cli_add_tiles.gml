///cli_add_tiles(tile_buffer)
///adds tiles as determined by server as well as room information

var tb = argument0;

if room != rmNetClient
  exit;

cli_clear_tiles_recent();
  
// add new tiles:
while (true) {
  var bgid = dec_bg(buffer_read(tb,buffer_s16))
  if (bgid == -1)
    return true;
  var dp = buffer_read(tb,buffer_f64)
  var left = buffer_read(tb,buffer_u16);
  var top = buffer_read(tb,buffer_u16);
  var width = buffer_read(tb,buffer_u8);
  var height = buffer_read(tb,buffer_u8);
  var tx = buffer_read(tb,buffer_u16)*16;
  var ty = buffer_read(tb,buffer_u16)*16;
  tile_add(bgid,
    left,
    top,
    width,
    height,
    tx,
    ty,
    dp)
}