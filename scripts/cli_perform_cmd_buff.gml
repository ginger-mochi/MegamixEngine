/// cli_perform_cmd_buff(cmd_buff)
/// gobbles one command from the commdand buffer and draws it

var cmd = argument0;
if buffer_tell(cmd) >= buffer_get_size(cmd)
    return false;

var opcode = buffer_read(cmd,buffer_s8);

switch opcode {
    case -1:
    case 0:
        return false;
    case 99: //room info
        cli_set_room_info(cmd);
        break;
    case 100: //tiles
        cli_add_tiles(cmd);
        break;
    case 101: //music
        playMusic(buffer_read(cmd, buffer_string),
            buffer_read(cmd, buffer_f32),
            buffer_read(cmd, buffer_f32));
        break;
     case 103:
        playSFX(buffer_read(cmd, buffer_s32))
        break;
     case 104: // view information
        view_xview[0] = buffer_read(cmd, buffer_s32);
        view_yview[0] = buffer_read(cmd, buffer_s32);
        break;
}

// more commands to process
return true;
