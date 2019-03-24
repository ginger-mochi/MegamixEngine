/// stateCodecInit()
/// intializes stateCodec subsystem

// maps from instance ID to unswizzled index.
global.stateCodecIDToUnswizzled = ds_map_create();
global.stateCodecUnswizzledToID = ds_map_create();
global.stateCodecUnswizzledCountByObject = ds_map_create();

// total number of stateCodecFull calls made.
global.stateCodecCount = 0;

// misc. globals that are not initialized elsewhere
stateCodecGlobalsInit();
