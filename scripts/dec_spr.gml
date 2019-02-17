/// dec_spr(spr)
// decodes sprite from enc_spr

if argument0 == -1
  return -1;
  
var spr = argument0 + objNet.eg_spr;
if argument0 < 0
  spr = argument0 + objNet.eg_spr + 1;

if (sprite_exists(spr))
{
    return spr;
}
return -1;
