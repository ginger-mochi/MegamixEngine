/// playSFX(index)
// Plays a sound effect

audio_stop_sound(argument0);

var mySound = audio_play_sound(argument0, 50, 0);
audio_sound_gain(mySound, global.soundvolume * 0.01, 0);

with objNet {
    if srv_isServing {
        //opcode
        buffer_write(cmd_buff, buffer_s8, 103);
        
        //argument
        buffer_write(cmd_buff, buffer_s32, argument0);
    }
}
