/// enc_bg(bg)
// encodes background into a small number

if argument0 == -1
  return -1;

var tmpval = argument0 - objNet.eg_bg
if tmpval < 0
  tmpval -= 1;
return tmpval;
