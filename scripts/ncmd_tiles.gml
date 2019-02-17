/// ncmd_tiles()
/// sends the room's tiles to the client

if (!objNet.srv_isServing)
    exit;

// rsetup room on client, including tiles 
buffer_seek(tile_buff, buffer_seek_start, 0);
tile_buff_chunk_n = 0;
tile_buff_chunk[0] = 0;

buffer_write(tile_buff, buffer_s8, 99);

buffer_write(tile_buff, buffer_s32, room_width);
buffer_write(tile_buff, buffer_s32, room_height);
buffer_write(tile_buff, buffer_s32, background_color);

// write backgrounds 
for (var i = 0; i < 8; i++)
{
    buffer_write(tile_buff, buffer_bool, background_visible[i]);
    buffer_write(tile_buff, buffer_s16, enc_bg(background_index[i]));
}

// write tiles 
buffer_write(tile_buff, buffer_s8, 100);

var tiles = tile_get_ids();

print("Sending tiles...");

var flush = 0;
for (var i = 0; i < array_length_1d(tiles); i++)
{
    // monitor buffer and chunk if it's getting too large:
    if (buffer_tell(tile_buff) > 400 * (tile_buff_chunk_n + 1))
    {
        buffer_write(tile_buff, buffer_s32, -1);
        tile_buff_chunk[++tile_buff_chunk_n] = buffer_tell(tile_buff);
        buffer_write(tile_buff, buffer_s8, 100);
        flush++;
        print("Chunk no. " + string(flush));
    }
    
    var t = tiles[i];
    
    var tdepth = tile_get_depth(t);
    var txscale = tile_get_xscale(t);
    var tyscale = tile_get_yscale(t);
    var tblend = tile_get_blend(t);
    var talpha = round(tile_get_alpha(t) * 255);
    var tx = tile_get_x(t);
    var ty = tile_get_y(t);
    var tl = tile_get_left(t);
    var tt = tile_get_top(t);
    var tw = tile_get_width(t);
    var th = tile_get_height(t);
    
    // two kinds of tiles: basic and complex.
    var basic = true;
    
    // check if depth is a signed integer
    if (clamp(round(tdepth), -2147483647, 2147483646) != tdepth)
    {
        basic = false;
    }
    // check if any unusual properties
    else if (txscale != 1 || tyscale != 1 || tblend != c_white || talpha != 255)
    {
        basic = false;
    }
    // check if dimensions or position non-grid-aligned
    else if (tx % 16 != 0 || tx < 0 || ty % 16 != 0 || ty < 0 || tx > 262143 || ty > 262143)
    {
        basic = false;
    }
    else if (tl % 16 != 0 || tl < 0 || tt % 16 != 0 || tt < 0 || tl > 255 || th > 255)
    {
        basic = false;
    }
    else if (tw % 16 != 0 || tw < 0 || th % 16 != 0 || th < 0 || tw > 255 || th > 255)
    {
        basic = false;
    }
    
    if (basic)
    {
        // background id
        buffer_write(tile_buff, buffer_s16, enc_bg(tile_get_background(t)));
        
        // depth
        buffer_write(tile_buff, buffer_s32, round(tdepth));
        
        // dimensions
        buffer_write(tile_buff, buffer_u8, floor(tile_get_left(t) / 16));
        buffer_write(tile_buff, buffer_u8, floor(tile_get_top(t) / 16));
        buffer_write(tile_buff, buffer_u8, floor(tile_get_width(t) / 16));
        buffer_write(tile_buff, buffer_u8, floor(tile_get_height(t) / 16));
        
        // x,y
        buffer_write(tile_buff, buffer_u16, round(tile_get_x(t) / 16));
        buffer_write(tile_buff, buffer_u16, round(tile_get_y(t) / 16));
    }
    else
    {
        // complicated tile
        buffer_write(tile_buff, buffer_s16, -2);
        
        // background id
        buffer_write(tile_buff, buffer_s16, enc_bg(tile_get_background(t)));
        
        // depth
        buffer_write(tile_buff, buffer_f64, tdepth);
        
        // dimensions
        buffer_write(tile_buff, buffer_s16, floor(tile_get_left(t)));
        buffer_write(tile_buff, buffer_s16, floor(tile_get_top(t)));
        buffer_write(tile_buff, buffer_s16, floor(tile_get_width(t)));
        buffer_write(tile_buff, buffer_s16, floor(tile_get_height(t)));
        
        // x,y
        buffer_write(tile_buff, buffer_f32, tx);
        buffer_write(tile_buff, buffer_f32, ty);
        
        // scale
        buffer_write(tile_buff, buffer_f32, txscale);
        buffer_write(tile_buff, buffer_f32, tyscale);
        
        // color
        buffer_write(tile_buff, buffer_u32, tblend);
        buffer_write(tile_buff, buffer_u8, talpha);
    }
}

buffer_write(tile_buff, buffer_s16, -1);
tile_buff_chunk[++tile_buff_chunk_n] = buffer_tell(tile_buff);

