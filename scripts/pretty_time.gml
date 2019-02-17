/// pretty_time (real)
// outputs string based on the input time

var seconds, minutes, hours, ms, s;

seconds = floor(argument0 % 60)
minutes = floor(argument0 div 60)
minutes = minutes % 60
hours = minutes div 60
ms = floor(1000 * (argument0 - floor(argument0)));

s = string_format(string(minutes), 2, 0) + ":"; // + string_format(string(seconds),2,0);
v = string_format(string(seconds), 2, 0);
repeat(2-string_length(v)) { v = "0" + v; }
s += v;

if (hours > 0)
{
    s = string(hours) + ":" + s
}

s = string_replace(s," ","0")

if (ms > 0)
{
    v = string(ms);
    repeat(3-string_length(v)){ v = "0" + v; }
    s += " " + v + "ms";
}
else
{
    s += "      "
}

return s;