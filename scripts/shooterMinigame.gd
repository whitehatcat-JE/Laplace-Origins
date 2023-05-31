extends Node2D

const STARTING_HEALTH:int = 3

var playerHealth:int = STARTING_HEALTH

@onready var brokenHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartBroken.png")
@onready var fullHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartFull.png")
@onready var spiderRobot:PackedScene = preload("res://objects/spiderRobot.tscn")
@onready var slimeRobot:PackedScene = preload("res://objects/slimeRobot.tscn")
@onready var droneRobot:PackedScene = preload("res://objects/droneRobot.tscn")

func _ready():
	_on_spawn_timer_timeout()

func playerHealed():
	if playerHealth >= 3: return;
	playerHealth += 1
	match playerHealth:
		3:
			$HUD/heartC.texture = fullHeartTexture
		2:
			$HUD/heartB.texture = fullHeartTexture
		1:
			$HUD/heartA.texture = fullHeartTexture

func _on_player_damage():
	if playerHealth > 0: playerHealth -= 1
	match playerHealth:
		2:
			$HUD/heartC.texture = brokenHeartTexture
		1:
			$HUD/heartB.texture = brokenHeartTexture
		0:
			$HUD/heartA.texture = brokenHeartTexture

func _on_spawn_timer_timeout():
	if randf_range(0, 1) > 0.98:
		var newRobot:Node = droneRobot.instantiate()
		add_child(newRobot)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newRobot.position = chosenSpawnpoint.position
		newRobot.velocity = Vector2(newRobot.SPEED, 0).rotated(newRobot.position.angle_to_point(
				chosenSpawnpoint.get_node("activationPoint").global_position))
		newRobot.heal.connect(playerHealed)
	else:
		var newRobot:Node = spiderRobot.instantiate() if randf_range(0, 1) > 0.2 else slimeRobot.instantiate()
		add_child(newRobot)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newRobot.position = chosenSpawnpoint.position
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newRobot, "position", chosenSpawnpoint.get_node("activationPoint").global_position, 0.5)
		spawnTween.tween_callback(newRobot.activate)
	$spawnTimer.start()
