/// cli_/*LOCAL*/ draw_gx_buff(gx_buff, [exclude])
/// gobbles one draw command from the graphics buffer and draws it

var gx = argument[0];
var exclude = false;
if argument_count > 1
  exclude = argument[1]

if buffer_tell(gx) >= buffer_get_size(gx)
    return false;

var opcode = buffer_read(gx,buffer_s8);

switch opcode {
    case -1:
        return false;
    case 1: ///*LOCAL*/ draw_sprite
        var spr    = dec_spr(buffer_read(gx,buffer_s16));
        var subimg = buffer_read(gx,buffer_u8);
        var spr_x  = buffer_read(gx,buffer_s16);
        var spr_y  = buffer_read(gx,buffer_s16);
        if exclude break;
        /*LOCAL*/ draw_sprite(spr,
                    subimg,
                    view_xview[0] + spr_x,
                    view_yview[0] + spr_y);
        break;
    case 2: ///*LOCAL*/ draw_sprite_ext
        var spr    = dec_spr(buffer_read(gx,buffer_s16));
        var subimg = buffer_read(gx,buffer_u8);
        var spr_x  = buffer_read(gx,buffer_s16);
        var spr_y  = buffer_read(gx,buffer_s16);
        var xscale = buffer_read(gx,buffer_f32);
        var yscale = buffer_read(gx,buffer_f32);
        var rot    = buffer_read(gx,buffer_f32);
        var color  = buffer_read(gx,buffer_u32);
        var alpha  = buffer_read(gx,buffer_f32);
        if exclude break;
        /*LOCAL*/ draw_sprite_ext(spr,
                    subimg,
                    view_xview[0] + spr_x,
                    view_yview[0] + spr_y,
                    xscale,
                    yscale,
                    rot,
                    color,
                    alpha)
        break;
    case 3: ///*LOCAL*/ draw_sprite_part
        var spr    = dec_spr(buffer_read(gx,buffer_s16));
        var subimg = buffer_read(gx,buffer_u8);
        var left   = buffer_read(gx,buffer_u16);
        var top    = buffer_read(gx,buffer_u16);
        var width  = buffer_read(gx,buffer_u16);
        var height =  buffer_read(gx,buffer_u16);
        var spr_x  = buffer_read(gx,buffer_s16);
        var spr_y  = buffer_read(gx,buffer_s16);
        if exclude break;
        /*LOCAL*/ draw_sprite_part(spr,
                    subimg,
                    left,
                    top,
                    width,
                    height,
                    view_xview[0] + spr_x,
                    view_yview[0] + spr_y)
        break;
    case 4: ///*LOCAL*/ draw_sprite_part_ext
        var spr    = dec_spr(buffer_read(gx,buffer_s16));
        var subimg = buffer_read(gx,buffer_u8);
        var left   = buffer_read(gx,buffer_u16);
        var top    = buffer_read(gx,buffer_u16);
        var width  = buffer_read(gx,buffer_u16);
        var height =  buffer_read(gx,buffer_u16);
        var spr_x  = buffer_read(gx,buffer_s16);
        var spr_y  = buffer_read(gx,buffer_s16);
        var xscale = buffer_read(gx,buffer_f32);
        var yscale = buffer_read(gx,buffer_f32);
        var color  = buffer_read(gx,buffer_u32);
        var alpha  = buffer_read(gx,buffer_f32);
        if exclude break;
        /*LOCAL*/ draw_sprite_part_ext(spr,
                    subimg,
                    left,
                    top,
                    width,
                    height,
                    view_xview[0] + spr_x,
                    view_yview[0] + spr_y,
                    xscale,
                    yscale,
                    color,
                    alpha)
        break;
    case 5: ///*LOCAL*/ draw_text
        var text_x = buffer_read(gx,buffer_s16);
        var text_y = buffer_read(gx,buffer_s16);
        var text_string = buffer_read(gx,buffer_string);
        if exclude break;
        /*LOCAL*/ draw_text(view_xview[0] + text_x,
                  view_yview[0] + text_y,
                  text_string);
        break;
    case 6: ///*LOCAL*/ draw_set_color
        /*LOCAL*/ draw_set_color(buffer_read(gx,buffer_u32));
        break;
    case 7: ///*LOCAL*/ draw_set_alpha
        /*LOCAL*/ draw_set_alpha(buffer_read(gx,buffer_f32));
        break;
    case 8: ///*LOCAL*/ draw_set_halign
        /*LOCAL*/ draw_set_halign(buffer_read(gx,buffer_s8));
        break;
    case 9: ///*LOCAL*/ draw_set_valign
        /*LOCAL*/ draw_set_valign(buffer_read(gx,buffer_s8));
        break;
    case 10: ///*LOCAL*/ draw_rectangles
        var rec_x1 = buffer_read(gx,buffer_s16);
        var rec_y1 = buffer_read(gx,buffer_s16);
        var rec_x2 = buffer_read(gx,buffer_s16);
        var rec_y2 = buffer_read(gx,buffer_s16);
        var rec_bool = buffer_read(gx,buffer_bool);
        if exclude break;
        /*LOCAL*/ draw_rectangle(view_xview[0] + rec_x1,
                       view_xview[0] + rec_y1,
                       view_xview[0] + rec_x2,
                       view_xview[0] + rec_y2,
                       rec_bool);
        break
    case 11: //exclude
        var player_id = buffer_read(gx, buffer_u16);
        for (j=0;j<loc_player_count;j += 1) {
            if loc_forwardControl_ids[j] == player_id
                break;
        }
        cli_draw_gx_buff(gx, true);
        break;
    case 12: // draw player (only if player is local)
        var player_id = buffer_read(gx, buffer_u16);
        var spr = dec_spr(buffer_read(gx, buffer_s16));
        var col;
        for (var i=0;i<4;i++) {
            col[i] = buffer_read(gx, buffer_u32);
        }
        
        var spriteX = buffer_read(gx, buffer_u8);
        var spriteY = buffer_read(gx, buffer_u8);
        
        var sx = view_xview[0] + buffer_read(gx, buffer_s16)
        var sy = view_yview[0] + buffer_read(gx, buffer_s16)
        
        var xscale = 1 - 2*buffer_read(gx, buffer_bool);
        var yscale = 1 - 2*buffer_read(gx, buffer_bool);
        
        SquareSize = 48;
        
        for (j=0;j<loc_player_count;j += 1) {
            if loc_forwardControl_ids[j] == player_id {
                for (var i=0;i<4;i++) {
                    /*LOCAL*/ draw_sprite_part_ext(
                        spr,i,
                        1+(floor(spriteX)*(SquareSize+3)),
                        1+(floor(spriteY)*(SquareSize+3)),
                        SquareSize,SquareSize,
                        round(sx)-(24*xscale),
                        round(sy)-(20*yscale),
                        xscale,yscale,
                        col[i],1
                    );
                }
                
                break;
            }
        }
        break;
}

// more commands to process
return true;
