extends Node
enum VSYNC_MODES {
	disabled,
	enabled,
	locked60
}

## Global variables
var progress:int = 0
var fromOutside:bool = false
# Settings
var sfxVolume:int = 10
var musicVolume:int = 10
var graphics:String = "HIGH"
var invertY:bool = false
var vsyncOrder:Array[VSYNC_MODES] = [VSYNC_MODES.enabled, VSYNC_MODES.locked60, VSYNC_MODES.disabled]
var vsyncNum:int = 0
# pcOS
var playerPos2D:Vector2 = Vector2()
var shooterActive:bool = false
var schrodingerActive:bool = false
var laplaceActive:bool = false
var slimyBirdActive:bool = false
var freeActive:bool = false
var hasFreeKey:bool = false
var freeDownloaded:bool = false
var pianoDoorUnlocked:bool = false
var inOS:bool = false
var flappyBirdActive:bool = false
# Stored basement scene location for when player is in city
var previousScreen:Node

@onready var steamLoaded:bool = Steam.isSteamRunning()
