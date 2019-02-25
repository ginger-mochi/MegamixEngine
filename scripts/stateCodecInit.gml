/// stateCodecInit()
/// intializes stateCodec subsystem

// maps from instance ID to unswizzled index.
global.stateCodecIDToUnswizzled = ds_map_create();
global.stateCodecUnswizzledToID = ds_map_create();
global.stateCodecUnswizzledCountByObject = ds_map_create();
