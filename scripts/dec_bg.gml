/// dec_bg(bg)
// decodes background from enc_bg

if argument0 == $ffff
  return -1;
if argument0 == $fffe
  return -2;
if argument0 == $fffd
  return -3;
if argument0 > $4fff
  return argument0 + objNet.eg_bg - $4fff;
return argument0 + objNet.eg_bg;
