extends Node
## Global variables
var progress:int = 0
# Settings
var sfxVolume:int = 0
var musicVolume:int = 0
var graphics:String = "High"
var invertY:bool = false
# pcOS
var playerPos2D:Vector2 = Vector2()
var shooterActive:bool = false
var freeActive:bool = false
var inOS:bool = false
# Stored basement scene location for when player is in city
var previousScreen:Node

func _input(event): if Input.is_action_pressed("forceQuit"): get_tree().quit();
