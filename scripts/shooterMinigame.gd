extends Node2D

const STARTING_HEALTH:int = 3
const STARTING_SPAWN_TIME:float = 3.0
var playerHealth:int = STARTING_HEALTH

var timeSinceStarted:float = 0.0

var allEnemies:Array[Node] = []
var score:int = 0

@onready var brokenHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartBroken.png")
@onready var fullHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartFull.png")
@onready var spiderRobot:PackedScene = preload("res://objects/spiderRobot.tscn")
@onready var slimeRobot:PackedScene = preload("res://objects/slimeRobot.tscn")
@onready var droneRobot:PackedScene = preload("res://objects/droneRobot.tscn")
@onready var motherfish:PackedScene = preload("res://objects/motherfish.tscn")

func start():
	GI.shooterActive = true

func stop():
	GI.shooterActive = false

func begin():
	$HUD/heartC.texture = fullHeartTexture
	$HUD/heartB.texture = fullHeartTexture
	$HUD/heartA.texture = fullHeartTexture
	score = 0
	playerHealth = STARTING_HEALTH
	$player.visible = true
	$player.alive = true
	$HUD/beginButton.visible = false
	$HUD/beginButton/interact/hitbox.set_deferred("disabled", true)
	_on_spawn_timer_timeout()
	timeSinceStarted = 0.0

func _process(delta):
	if !GI.shooterActive: return;
	timeSinceStarted += delta

func playerHealed():
	if playerHealth >= 3:
		score += 500
		return
	playerHealth += 1
	match playerHealth:
		3: $HUD/heartC.texture = fullHeartTexture;
		2: $HUD/heartB.texture = fullHeartTexture;
		1: $HUD/heartA.texture = fullHeartTexture;

func _on_player_damage():
	if playerHealth > 0: playerHealth -= 1
	match playerHealth:
		2: $HUD/heartC.texture = brokenHeartTexture;
		1: $HUD/heartB.texture = brokenHeartTexture;
		0:
			$HUD/heartA.texture = brokenHeartTexture
			$player.alive = false
			$spawnTimer.stop()
			$HUD/beginButton.visible = true
			$player.visible = false
			$HUD/beginButton/interact/hitbox.set_deferred("disabled", false)
			if score == 0: $HUD/beginButton/score.text = "";
			else: $HUD/beginButton/score.text = "Score: " + str(score);
			while len(allEnemies) > 0:
				var nextEnemy = allEnemies.pop_front()
				if nextEnemy != null: nextEnemy.kill()

func _on_spawn_timer_timeout():
	if !$player.alive: return;
	$spawnTimer.wait_time = STARTING_SPAWN_TIME * pow(0.995, timeSinceStarted + 1.0)
	if randf() > 0.98:
		var newDrone:Node = droneRobot.instantiate()
		add_child(newDrone)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newDrone.position = chosenSpawnpoint.position
		newDrone.velocity = Vector2(newDrone.SPEED, 0).rotated(newDrone.position.angle_to_point(
				chosenSpawnpoint.get_node("activationPoint").global_position))
		newDrone.heal.connect(playerHealed)
		allEnemies.append(newDrone)
	elif randf() > 0.95 and timeSinceStarted > 60.0:
		var newBoss:Node = motherfish.instantiate()
		allEnemies.append(newBoss)
		add_child(newBoss)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		var moveAngle:float = chosenSpawnpoint.position.angle_to_point(
			chosenSpawnpoint.get_node("activationPoint").global_position)
		newBoss.position = chosenSpawnpoint.position - Vector2(100, 0).rotated(moveAngle)
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newBoss, "position", 
			chosenSpawnpoint.get_node("activationPoint").global_position + Vector2(
				100 * randf_range(0.8, 1.5), 0).rotated(moveAngle), 7)
		spawnTween.tween_callback(newBoss.activate)
	else:
		var newRobot:Node = spiderRobot.instantiate() if randf() > 0.2 or timeSinceStarted < 20.0 else slimeRobot.instantiate()
		allEnemies.append(newRobot)
		add_child(newRobot)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newRobot.position = chosenSpawnpoint.position
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newRobot, "position", chosenSpawnpoint.get_node("activationPoint").global_position, 0.5)
		spawnTween.tween_callback(newRobot.activate)
	$spawnTimer.start()
