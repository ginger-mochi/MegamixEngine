// array2dMaxLength(array)
// returns maximum length of any row in the array

var arr = argument0;
var l = 0;
for (var i = 0; i < array_height_2d(arr); i++)
{
    l = max(l, (array_length_2d(arr, i)))
}

return l;
