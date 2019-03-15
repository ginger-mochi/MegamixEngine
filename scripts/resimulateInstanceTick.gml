/// resimulateInstanceTick()
// updates built-in variables on instance.
// ignores collision and path movement.

// update animation.
if (image_speed != 0)
{
    var next_image_index = image_index + image_speed;
    image_index = next_image_index;
    if (next_image_index >= image_number)
    {
        event_perform(ev_other, ev_animation_end);
    }
}

// apply gravity
if (gravity != 0)
{
    hspeed += dcos(gravity_direction) * gravity;
    vspeed -= dsin(gravity_direction) * gravity;
}

// collisions are not accounted for, including solid object collisions.
xprevious = x;
yprevious = y;
x += hspeed;
y += vspeed;

// timers (consider removing this for speedup?)
for (var i = 0; i < 12; i++)
{
    if (alarm[i] > 0)
    {
        alarm[i] -= 1;
        if (alarm[i] == 0)
        {
            event_perform(ev_alarm, i);
        }
    }
}
