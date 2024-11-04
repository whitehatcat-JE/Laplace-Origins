extends Node2D
# Constants
const GRAVITY:float = 550.0
const TERMINAL_VELOCITY:float = 200.0
const JUMP_HEIGHT:float = 200.0

const PILLAR_SPAWN_TIME:float = 1.5
# State variables
var alive:bool = false
var velocity:float = 0.0

var timeSinceLastPillar:float = PILLAR_SPAWN_TIME

var score = -4
# Nodes
@onready var pillarObj:PackedScene = preload("res://objects/minigames/slimyBirdpillar.tscn")
# Called once per frame
func _process(delta):
	if alive:
		# Move background
		increaseRect($backdrop/CloudsA, 25.0 * delta)
		increaseRect($backdrop/CloudsB, 10.0 * delta)
		increaseRect($backdrop/floor, 50.0 * delta)
		# Move player
		velocity = clamp(velocity + GRAVITY * delta, -100000, TERMINAL_VELOCITY)
		if Input.is_action_just_pressed("jump") and GI.inOS:
			velocity = -JUMP_HEIGHT
			$jumpSFX.play()
		elif $backdrop/character.is_on_ceiling() and velocity < 0:
			velocity = 0.0
		$backdrop/character.velocity.y = velocity
		$backdrop/character.move_and_slide()
		
		$backdrop/character/slime.rotation_degrees = velocity / 8.0
		# Spawn new pillars
		timeSinceLastPillar += delta
		if timeSinceLastPillar > PILLAR_SPAWN_TIME:
			var newPillar:Node2D = pillarObj.instantiate()
			$backdrop/pillars.add_child(newPillar)
			newPillar.speed = 50.0
			newPillar.position.y += randf_range(0.0, 65.0)
			timeSinceLastPillar = 0.0
			score += 1
# Move give rect
func increaseRect(obj:Sprite2D, amt:float):
	var rect:Rect2 = obj.get_region_rect()
	rect.position.x += amt
	obj.set_region_rect(rect)
# Activate slimybird minigame
func start():
	alive = true
	GI.slimyBirdActive = true
	$startButton.position.x = 10000.0
	$backdrop/floor/floorBody.position.y = 0
	$backdrop/character/hitbox.set_deferred("disabled", false)
# Stop slimybird minigame
func stop():
	# Reset game state
	GI.slimyBirdActive = false
	alive = false
	timeSinceLastPillar = PILLAR_SPAWN_TIME
	for pillar in $backdrop/pillars.get_children(): pillar.queue_free();
	var cloudARect:Rect2 = $backdrop/CloudsA.get_region_rect()
	var cloudBRect:Rect2 = $backdrop/CloudsB.get_region_rect()
	cloudARect.position.x = 0.0
	cloudBRect.position.x = 0.0
	$backdrop/floor/floorBody.position.y = 10000.0
	$backdrop/CloudsA.set_region_rect(cloudARect)
	$backdrop/CloudsB.set_region_rect(cloudBRect)
	$startButton.position.x = 1071.222
	# De-activate player
	$backdrop/character/slime.rotation_degrees = 0.0
	$backdrop/character.position.y = 0.0
	$backdrop/character/hitbox.set_deferred("disabled", true)
	# Give player achievement if they survive 30 pillars
	if GI.steamLoaded and score >= 30: Steam.setAchievement("SH_BIRD");
	# Update highscore
	if score > 0 or $startButton/score.text != "":
		$startButton/score.text = "Score: " + str(clamp(score, 0, 10000000))
	score = -4
# Kill player
func _on_pillar_scanner_area_entered(area):
	$deathSFX.play()
	stop()
