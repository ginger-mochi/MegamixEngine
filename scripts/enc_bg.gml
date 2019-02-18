/// enc_bg(bg)
// encodes background into a small number

if (argument0 == -1)
  return $ffff;
if (argument0 == -2)
  return $fffe;
if (argument0 == -3)
  return $fffd;

var tmpval = argument0 - objNet.eg_bg
if tmpval < 0
  tmpval += $4fff;
return tmpval;
