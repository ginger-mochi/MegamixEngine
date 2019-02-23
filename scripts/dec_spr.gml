/// dec_spr(spr)
// decodes sprite from enc_spr

if argument0 == -1
  return -1;
if argument0 < 0
  return argument0 + objNet.eg_spr + 1;
return argument0 + objNet.eg_spr;
