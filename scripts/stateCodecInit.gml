/// stateCodecInit()
/// intializes stateCodec subsystem

// maps from instance ID to unswizzled index.
global.stateCodecIDToUnswizzled = ds_map_create();
global.stateCodecUnswizzledToID = ds_map_create();
global.stateCodecUnswizzledCountByObject = ds_map_create();

// misc. globals that are not initialized elsewhere

global.alwaysHealth = 0;
global.automapper = 0;
global.beginHubOnRoomBegin = 0;
global.borderLockBottom = 0;
global.borderLockLeft = 0;
global.borderLockRight = 0;
global.borderLockTop = 0;
global.BounceXVel = 0;
global.costumeRequirement = 0;
global.createArgument = 0;
global.currentsavefile = 0;
global.disableChargeUpgrade = 0;
global.disableConverter = 0;
global.disableDropUpgrade = 0;
global.disableShotUpgrade = 0;
global.disableSkullAmulet = 0;
global.disableSturdyHelmet = 0;
global.eddieisdead = 0;
global.eventArgs = 0;
global.execute_gml_function_ERR = 0;
global.familyFriendlyText = 0;
global.flag = 0;
global.flagParent = 0;
global.freeMovement = 0;
global.gml_fn_retval = 0;
global.gravityLiftBulletMap = 0;
global.gravityLiftLockJumpMap = 0;
global.gravityLiftLockMap = 0;
global.gravityLiftXSpeedMap = 0;
global.gunshot = 0;
global.isInvincible = 0;
global.levelLoop = 0;
global.levelLoopEnd = 0;
global.levelLoopStart = 0;
global.levelRunInvalidReason = 0;
global.levelRunValid = 0;
global.levelSong = 0;
global.levelSongType = 0;
global.levelTrackNumber = 0;
global.levelVolume = 0;
global.leverPropagated = 0;
global.lockAvailable = 0;
global.MeBounce = 0;
global.musicsound = 0;
global.playerSpriteMax = 0;
global.playingcustommusic = 0;
global.retval = 0;
global.retval_error = 0;
global.retval_exprlen = 0;
global.retval_exprval = 0;
global.roomReturnIsHub = 0;
global.sectionBottom = 0;
global.sectionLeft = 0;
global.sectionRight = 0;
global.sectionTop = 0;
global.sheepBlockStack = 0;
global.sheepBlockStack_n = 0;
global.showMovingText = 0;
global.songMemory = 0;
global.stageStartRoom = 0;
global.teleportX = 0;
global.teleportY = 0;
global.tempSongData = 0;
global.tileLayers = 0;
global.tileLayersN = 0;
global.waveManWarpLock = 0;
