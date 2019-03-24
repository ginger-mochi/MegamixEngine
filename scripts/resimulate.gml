/// netplayResimulate(n, eventPhase)
/// resimulates n frames without drawing.
/// eventPhase is the phase to start resimulating on and to end just before resimulating.
/// it can be ev_step_begin, ev_step_end, ev_step_normal

var n = argument[0];
var eventPhase = argument[1];
var startTime = current_time;

switch (eventPhase)
{
case ev_step_begin:
    for (var i = 0; i < n; i++)
    {
        resimulatePhase(-1); // resimulateInstanceTick
        resimulatePhase(ev_step_begin);
        resimulatePhase(ev_step_normal);
        resimulatePhase(ev_step_end);
        // draw event
    }
    break;
case ev_step_normal:
    for (var i = 0; i < n; i++)
    {
        resimulatePhase(ev_step_normal);
        resimulatePhase(ev_step_end);
        // draw event
        resimulatePhase(-1); // resimulateInstanceTick
        resimulatePhase(ev_step_begin);
    }
    break;
case ev_step_end:
    for (var i = 0; i < n; i++)
    {
        resimulatePhase(ev_step_end);
        // draw event
        resimulatePhase(-1); // resimulateInstanceTick
        resimulatePhase(ev_step_begin);
        resimulatePhase(ev_step_normal);
    }
    break;
default:
        assert(false, "Invalid resimulation phase.");
}

var timeElapsed = current_time - startTime;
print(string(timeElapsed) + " ms to resimulate " + string(n) + " frames.");
