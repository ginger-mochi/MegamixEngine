/// resimulateEvent(event_subtype)
/// resimulates the given update tick for all instances.
//  -1 (update tick)
//  ev_step_begin
//  ev_step_normal
//  ev_step_end

var skipInstance = id;

// problem: 'with' statement executes in order of depth, but
// in this case it needs to execute in order of resource tree index.

switch (argument0)
{
    case -1:
        with (all) if (id == skipInstance) continue else 
        {
            resimulateInstanceTick();
        }
        break;
    case ev_step_begin:
        with (all) if (id == skipInstance) continue else 
        {
            event_perform(ev_step, ev_step_begin);
        }
        break;
    case ev_step_normal:
        with (all) if (id == skipInstance) continue else 
        {
            event_perform(ev_step, ev_step_normal);
        }
        break;
    case ev_step_end:
        with (all) if (id == skipInstance) continue else 
        {
            event_perform(ev_step, ev_step_end);
        }
        break;
    default:
        assert(false, "Invalid netplay resimulation phase.");
}
