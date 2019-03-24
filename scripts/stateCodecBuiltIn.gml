/// stateCodecBuiltIn()
// serializes built-in global variables.

if (global.stateCodecEncode)
{
    buffer_write(global.stateCodecBuffer, buffer_f32, view_xview[0]);
    buffer_write(global.stateCodecBuffer, buffer_f32, view_yview[0]);
    buffer_write(global.stateCodecBuffer, buffer_u32, background_color);
}
else
{
    view_xview[0] = buffer_read(global.stateCodecBuffer, buffer_f32);
    view_yview[0] = buffer_read(global.stateCodecBuffer, buffer_f32);
    background_color = buffer_read(global.stateCodecBuffer, buffer_u32);
}

// serialize random seed (modifies seed in order to be loadable.)
if (global.stateCodecEncode)
{
    var newSeed = irandom($ffffff);
    random_set_seed(newSeed);
    var check = irandom($ffffff);
    buffer_write(global.stateCodecBuffer, buffer_s32, newSeed);
    buffer_write(global.stateCodecBuffer, buffer_s32, check);
}
else
{
    var newSeed = buffer_read(global.stateCodecBuffer, buffer_s32);
    var check = buffer_read(global.stateCodecBuffer, buffer_s32);
    random_set_seed(newSeed);
    assert(check == irandom($ffffff), "random seed determinism check failed.")
}
