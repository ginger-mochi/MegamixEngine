/// dec_bg(bg)
// decodes background from enc_bg

if argument0 == -1
  return -1;
if argument0 == -2
  return -2;
if argument0 < 0
  return argument0 + objNet.eg_bg + 2;
return argument0 + objNet.eg_bg;
