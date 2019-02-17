/// cli_add_tiles(tile_buffer)
/// adds tiles as determined by server as well as room information

var tb = argument0;

if (room != rmNetClient)
    exit;

cli_clear_tiles_recent();

// add new tiles: 
while (true)
{
    var bgid = dec_bg(buffer_read(tb, buffer_s16));
    
    if (bgid == -1)
        return true;
    if (bgid != -2)
    {
        // basic tile
        if (!background_exists(bgid))
        {
            print("Received unknown tile bgid from server.")
            return false;
        }
    
        // read properties
        var tdepth = buffer_read(tb, buffer_s32);
        var left = buffer_read(tb, buffer_u8) * 16;
        var top = buffer_read(tb, buffer_u8) * 16;
        var width = buffer_read(tb, buffer_u8) * 16;
        var height = buffer_read(tb, buffer_u8) * 16;
        var tx = buffer_read(tb, buffer_u16) * 16;
        var ty = buffer_read(tb, buffer_u16) * 16;
        tile_add(
            bgid,
            left,
            top,
            width,
            height,
            tx,
            ty,
            tdepth);
    }
    else
    {
        // complicated tile
        if (!background_exists(bgid))
        {
            print("Received unknown tile bgid from server.")
            return false;
        }
        
        // read background index again (-2 was extension marker)
        bgid = dec_bg(buffer_read(tb, buffer_s16));
        
        // read properties
        var tdepth = buffer_read(tb, buffer_f64);
        var left = buffer_read(tb, buffer_s16);
        var top = buffer_read(tb, buffer_s16);
        var width = buffer_read(tb, buffer_s16);
        var height = buffer_read(tb, buffer_s16);
        var tx = buffer_read(tb, buffer_f32);
        var ty = buffer_read(tb, buffer_f32);
        var txscale = buffer_read(tb, buffer_f32);
        var tyscale = buffer_read(tb, buffer_f32);
        var tblend = buffer_read(tb, buffer_u32);
        var talpha = buffer_read(tb, buffer_u8) / 255;
        
        var t = tile_add(bgid, left, top, width, height, tx, ty, dp);
        tile_set_scale(t, txscale, tyscale);
        tile_set_blend(t, tblend);
        tile_set_alpha(t, talpha);
    }
}
