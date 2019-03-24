/// stateCodecFull()
/// serializes/deserializes the current game state into the provided buffer.
/// ensure these globals are set:
/// global.stateCodecBuffer - buffer to write/read
/// global.stateCodecEncode - if true, write; if false, read

global.stateCodecCount++;
var startTime = current_time;

// serialize game state information
stateCodecBuiltIn();
stateCodecGlobals();

// serialize all instances

if (global.stateCodecEncode)
{
    // TODO: consider deactivated instances
    // TODO: clean up id map, removing deleted instances..
    
    ds_map_clear(global.stateCodecUnswizzledToID);
    ds_map_clear(global.stateCodecIDToUnswizzled);
    
    // assign unswizzled IDs.
    var unswizzled_id = 0;
    with (all)
    {
        ds_map_replace(global.stateCodecUnswizzledToID, unswizzled_id, id);
        ds_map_replace(global.stateCodecIDToUnswizzled, id, unswizzled_id);
                    
        var objectIndexEncoded = object_index - global.firstObject;
        assert(objectIndexEncoded >= 0, "encoded object index negative: " + object_get_name(object_index));
        
        // write object index
        assert(unswizzled_id != $ffff);
        buffer_write(global.stateCodecBuffer, buffer_u16, unswizzled_id);
        buffer_write(global.stateCodecBuffer, buffer_u16, objectIndexEncoded);
        unswizzled_id++;
    }
    
    // end marker
    buffer_write(global.stateCodecBuffer, buffer_u16, $ffff);
    
    with (all)
    {
        // codec event
        // note: adding unswizzled id might not be necessary here...
        var unswizzled_id = ds_map_find_value(global.stateCodecIDToUnswizzled, id);
        assert(!is_undefined(unswizzled_id));
        buffer_write(global.stateCodecBuffer, buffer_u16, unswizzled_id);
        event_user(EV_CODEC);
    }
    
    // end marker
    buffer_write(global.stateCodecBuffer, buffer_u16, $ffff);
}
else
{
    // deserialize
    ds_map_clear(global.stateCodecUnswizzledToID);
    ds_map_clear(global.stateCodecIDToUnswizzled);
    ds_map_clear(global.stateCodecUnswizzledCountByObject);
    var objects;
    var objectCount = 0;
    
    // collect list of objects (required to delete objects of which there are none in the save state.)
    // initialize their counts to 0.
    with all
    {
        var previous_count = ds_map_find_value(global.stateCodecUnswizzledCountByObject, object_index);
        if (is_undefined(previous_count))
        {
            ds_map_replace(global.stateCodecUnswizzledCountByObject, object_index, 0);
            objects[objectCount++] = object_index;
        }
    }
    
    // read unswizzled-object_index map, assign unswizzled ids to instances.
    while (true)
    {
        var unswizzled_id = buffer_read(global.stateCodecBuffer, buffer_u16);
        if (unswizzled_id == $ffff)
        {
            break;
        }
        
        var _object_index = buffer_read(global.stateCodecBuffer, buffer_u16) + global.firstObject;
        assert(object_exists(_object_index));
        
        // update count of objects per instance
        var previous_count = ds_map_find_value(global.stateCodecUnswizzledCountByObject, _object_index);
        if (is_undefined(previous_count))
        {
            previous_count = 0;
            objects[objectCount++] = _object_index;
        }
        ds_map_replace(global.stateCodecUnswizzledCountByObject, _object_index, previous_count + 1);
        
        var host_id = instance_find(_object_index, previous_count);
        
        // create a new host if none exists
        // to avoid running create event, create a dummy instance and then change it.
        if (host_id == noone)
        {
            host_id = instance_create(0, 0, objStruct);
            with (host_id)
            {
                instance_change(_object_index, false);
            }
        }
        
        // map to instance.
        ds_map_replace(global.stateCodecUnswizzledToID, unswizzled_id, host_id);
        ds_map_replace(global.stateCodecIDToUnswizzled, host_id, unswizzled_id);
    }
    
    // destroy excess instances.
    var instanceArray;
    deleteInstanceArray[500] = 0;
    for (var keyIter = 0; keyIter < objectCount; keyIter++)
    {
        var _object_index = objects[keyIter];
        var instanceCount = ds_map_find_value(global.stateCodecUnswizzledCountByObject, _object_index);
        var deleteCount = 0;
        
        // collect list of instances to delete.
        for (var i = instanceCount; i < instance_number(_object_index); i++)
        {
            deleteInstanceArray[deleteCount++] = instance_find(_object_index, i);
        }
        
        // delete instances.
        for (var i = 0; i < deleteCount; i++)
        {
            with (deleteInstanceArray[i])
            {
                print("deleted excess " + object_get_name(object_index));
                
                // change to struct to avoid performing destroy event.
                instance_change(objStruct, false);
                instance_destroy();
            }
        }
    }
    
    // decode for each instance.
    print("Decoding instance data.")
    print(buffer_tell(global.stateCodecBuffer));
    while (true)
    {
        var unswizzled_id = buffer_read(global.stateCodecBuffer, buffer_u16);
        if (unswizzled_id == $ffff)
        {
            break;
        }
        else
        {
            var _id = ds_map_find_value(global.stateCodecUnswizzledToID, unswizzled_id);
            assert(!is_undefined(_id), "undefined swizzled id");
            with (_id)
            {
                event_user(EV_CODEC);
            }
        }
    }
    
    print("All instances decoded.");
    
}

var timeElapsed = current_time - startTime;
if (global.stateCodecEncode)
{
    print(string(timeElapsed) + " ms to serialize.");
}
else
{
    print(string(timeElapsed) + " ms to deserialize.");
}
