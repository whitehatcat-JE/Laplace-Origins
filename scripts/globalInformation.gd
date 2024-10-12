extends Node
## Global variables
var progress:int = 0
# Settings
var sfxVolume:int = 10
var musicVolume:int = 10
var graphics:String = "HIGH"
var invertY:bool = false
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

func _input(event): if Input.is_action_pressed("forceQuit"): get_tree().quit();
