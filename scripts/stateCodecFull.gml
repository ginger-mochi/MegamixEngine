/// stateCodecFull()
/// serializes/deserializes the current game state into the provided buffer.
/// ensure these globals are set:
/// global.stateCodecBuffer - buffer to write/read
/// global.stateCodecEncode - if true, write; if false, read

// serialize game state information

// serialize globals

// serialize all instances

if (global.stateCodecEncode)
{
    // TODO: consider deactivated instances
    // TODO: clean up id map, removing deleted instances..
    with (all)
    {
        var unswizzled_id = ds_map_find_value(global.stateCodecIDToUnswizzled, id);
        if (is_undefined(unswizzled_id))
        {
            unswizzled_id = 0;
            // assign new unswizzled ID
            while (true)
            {
                if (is_undefined(ds_map_find_value(global.stateCodecUnswizzledToID, new_id)))
                {
                    ds_map_replace(global.stateCodecUnswizzledToID, unswizzled_id, id);
                    ds_map_replace(global.stateCodecIDToUnswizzled, id, unswizzled_id);
                    break;
                }
                unswizzled_id++;
            }
        }
        var objectIndexEncoded = object_index - global.firstObject;
        assert(objectIndexEncoded >= 0, "encoded object index negative: " + object_get_name(object_index));
        
        // write object index
        buffer_write(global.stateCodecBuffer, buffer_u16, unswizzled_id);
        buffer_write(global.stateCodecBuffer, buffer_u16, objectIndexEncoded);
    }
    
    // end marker
    buffer_write(global.stateCodecBuffer, buffer_u16, $ffff);
    
    // let's hope with statements execute deterministically.
    with (all)
    {
        // codec event
        // note: adding unswizzled id might not be necessary here...
        var unswizzled_id = ds_map_find_value(global.stateCodecIDToUnswizzled, id);
        buffer_write(global.stateCodecBuffer, buffer_u16, unswizzled_id);
        event_user(EV_CODEC);
    }
    
    // end marker
    buffer_write(global.stateCodecBuffer, buffer_u16, $ffff);
}
else
{
    // read unswizzled-object_index map, assign unswizzled ids to instances.
    ds_map_clear(global.stateCodecUnswizzledToID);
    ds_map_clear(global.stateCodecIDToUnswizzled);
    var objects;
    var objectCount = 0;
    while (true)
    {
        var unswizzled_id = buffer_read(global.stateCodecBuffer, buffer_u16);
        if (unswizzled_id == $ffff)
        {
            break;
        }
        
        var _object_index = buffer_read(global.stateCodecBuffer, buffer_u16) + global.firstObject;
        
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
        host_id = instance_create(0, 0, objStruct);
        with (host_id)
        {
            instance_change(_object_index, false);
        }
        
        // map to instance.
        ds_map_replace(global.stateCodecUnswizzledToID, unswizzled_id, host_id);
        ds_map_replace(global.stateCodecIDToUnswizzled, host_id, unswizzled_id);
    }
    
    // destroy excess instances.
    for (var keyIter = 0; keyIter < objectCount; keyIter++)
    {
        var _object_index = objects[keyIter];
        var instanceCount = ds_map_find_value(global.stateCodecUnswizzledCountByObject, _object_index);
        for (var i = instanceCount; true; i++)
        {
            var instance = instance_find(_object_index, i);
            with (instance)
            {
                instance_destroy();
                continue;
            }
            
            // break if no instance.
            break;
        }
    }
    
    // decode for each instance.
    while (true)
    {
        var unswizzled_id = buffer_read(global.stateCodecBuffer, buffer_u16);
        if (unswizzled_id == $ffff)
        {
            break;
        }
        else
        {
            var _id = ds_map_find_value(global.stateCodecUnswizzledToID, new_id);
            assert(!is_undefined(_id), "undefined swizzled id");
            with (_id)
            {
                event_user(EV_CODEC);
            }
        }
    }
}
