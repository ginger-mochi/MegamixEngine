/// cli_add_tiles(tile_buffer)
/// adds tiles as determined by server as well as room information

var tb = argument0;

if (room != rmNetClient)
    return false;

cli_clear_tiles_recent();

var prev_bgid, prev_tdepth, prev_tw, prev_th, prev_tx, prev_ty;
var compression_permitted = false;

// add new tiles: 
while (true)
{
    // header byte (may be part of background index)
    var u8a = buffer_read(tb, buffer_u8);
    
    if (u8a == $ff)
        return true;
    if (u8a != $fe)
    {
        // basic tile
        var compressed    = u8a == $40;
        var abscompressed = u8a == $41;
        
        var bgid, tdepth, left, top, width, height, tx, ty, ttexpos, tdim, tw, th;
        if (compressed || abscompressed)
        {
            // highly compressed form (valid only if previous tile's properties can carry forward)
            if (!compression_permitted || !buffer_has(tb, 2))
            {
                // panic
                return false;
            }
            
            ttexpos = buffer_read(tb, buffer_u8);
            
            // reuse previous values
            bgid = prev_bgid;
            tdepth = prev_tdepth;
            tw = prev_tw;
            th = prev_th;
            tx = prev_tx;
            ty = prev_ty;
            
            // x/y varies
            if (compressed)
            {
                // delta position                
                var tdelta = buffer_read(tb, buffer_u8);
                var tdx    = ((tdelta & $f0) >> 4) - 8;
                var tdy    = (tdelta & $0f) - 8;
                
                tx += tdx * 16;
                ty += tdy * 16;
                
                // 3 bytes total.
            }
            else
            {
                // absolute position
                if (!buffer_has(tb, 4))
                {
                    // panic 
                    return false;
                }
                tx = buffer_read(tb, buffer_u16) * 16;
                ty = buffer_read(tb, buffer_u16) * 16;
                
                // 6 bytes total.
            }
        }
        else
        {
            // full basic form
            if (!buffer_has(tb, 12))
            {
                // panic 
                return false;
            }
            
            compression_permitted = true;
            var u8b = buffer_read(tb, buffer_u8);
            bgid    = dec_bg((u8a << 8) | u8b);
            tdepth  = buffer_read(tb, buffer_s32);
            ttexpos = buffer_read(tb, buffer_u8);
            tdim    = buffer_read(tb, buffer_u8);
            tx      = buffer_read(tb, buffer_u16) * 16;
            ty      = buffer_read(tb, buffer_u16) * 16;
            
            tw = ((tdim & $f0) >> 4) * 16;
            th = (tdim & $0f) * 16;
            
            prev_tw = tw;
            prev_th = th;
            prev_bgid = bgid;
            prev_tdepth = tdepth;            
            // 12 bytes total.
        }
        
        left = ((ttexpos & $f0) >> 4) * 16
        top = (ttexpos & $0f) * 16;
        prev_tx = tx;
        prev_ty = ty;
        
        if (!background_exists(bgid))
        {
            print("Received unknown tile bgid from server.")
            return false;
        }
    
        tile_add(
            bgid,
            left,
            top,
            tw,
            th,
            tx,
            ty,
            tdepth);
    }
    else
    {
        // complicated tile
        if (!buffer_has(tb, 40))
        {
            // panic 
            return false;
        }
            
        // properties will not carry forward for compressed form.
        compression_permitted = false;
        
        // read background index again ($fe was extension marker)
        bgid = dec_bg(buffer_read(tb, buffer_u16));
        
        if (!background_exists(bgid))
        {
            print("Received unknown tile bgid from server.")
            return false;
        }
        
        // read properties
        var tdepth =  buffer_read(tb, buffer_f64);
        var left =    buffer_read(tb, buffer_s16);
        var top =     buffer_read(tb, buffer_s16);
        var width =   buffer_read(tb, buffer_s16);
        var height =  buffer_read(tb, buffer_s16);
        var tx =      buffer_read(tb, buffer_f32);
        var ty =      buffer_read(tb, buffer_f32);
        var txscale = buffer_read(tb, buffer_f32);
        var tyscale = buffer_read(tb, buffer_f32);
        var tblend =  buffer_read(tb, buffer_u32);
        var talpha =  buffer_read(tb, buffer_u8) / 255;
        
        var t = tile_add(bgid, left, top, width, height, tx, ty, tdepth);
        tile_set_scale(t, txscale, tyscale);
        tile_set_blend(t, tblend);
        tile_set_alpha(t, talpha);
        
        // 40 bytes total.
    }
}
