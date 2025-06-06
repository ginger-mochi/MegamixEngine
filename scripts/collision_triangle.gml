/// collision_triangle(x1,y1,x2,y2,x3,y3,object)
//
//  Returns true if there is a collision between a given
//  triangle and a given object, false otherwise.
//
//      x1,y1       first point of triangle (filled), real
//      x2,y2       second point of triangle (filled), real
//      x3,y3       third point of triangle (filled), real
//      object      object or instance (or all), real
//
/// GMLscripts.com/license
{
   var x1,y1,x2,y2,x3,y3,object,xmin,xmax,ymin,ymax,d12,d13,d23,d14,d24,t,dx,dy,x4,y4;
   x1 = argument0;
   y1 = argument1;
   x2 = argument2;
   y2 = argument3;
   x3 = argument4;
   y3 = argument5;
   object = argument6;
 
   // Bounding box check
   xmin = min(x1,x2,x3);
   xmax = max(x1,x2,x3);
   ymin = min(y1,y2,y3);
   ymax = max(y1,y2,y3);
   if (not collision_rectangle(xmin,ymin,xmax,ymax,object,false,false)) return false;
 
   // Triangle perimeter check
   if (collision_line(x1,y1,x2,y2,object,true,false)) return true;
   if (collision_line(x1,y1,x3,y3,object,true,false)) return true;
   if (collision_line(x2,y2,x3,y3,object,true,false)) return true;
 
   // Find long side, make it (x1,y2) to (x2,y2)
   d12 = point_distance(x1,y1,x2,y2);
   d13 = point_distance(x1,y1,x3,y3);
   d23 = point_distance(x2,y2,x3,y3);
   switch (max(d12,d13,d23)) {
       case d13:
           t = x2; x2 = x3; x3 = t;
           t = y2; y2 = y3; y3 = t;
           d12 = d13;
           break;
       case d23:
           t = x1; x1 = x3; x3 = t;
           t = y1; y1 = y3; y3 = t;
           d12 = d23;
           break;
   }
 
   // From (x3,y3), find nearest point on long side (x4,y4).
   dx = x2 - x1;
   dy = y2 - y1;
   if ((dx == 0) && (dy == 0)) {
       x4 = x1;
       y4 = y1;
   }else{
       t = ((x3 - x1) * dx + (y3 - y1) * dy) / (d12 * d12);
       x4 = x1 + t * dx;
       y4 = y1 + t * dy;
   }
 
   // A line constructed from (x3,y3) to (x4,y4) divides
   // the original triangle into two right triangles.
   // Fit the collision mask into these triangles.
   d14 = point_distance(x1,y1,x4,y4);
   d24 = d12 - d14;
   return false;
}
