extends Node2D

signal laplaceSpawned

const STARTING_HEALTH:int = 3
const STARTING_SPAWN_TIME:float = 2.5
var playerHealth:int = STARTING_HEALTH

var timeSinceStarted:float = 0.0

var allEnemies:Array[Node] = []
var score:int = 0

var corrupted:bool = false
var laplaceDescended:bool = false
var laplaceBulletSpeed = 1.0

@onready var brokenHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartBroken.png")
@onready var fullHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartFull.png")
@onready var beginTexture:Texture = preload("res://assets/2d/shooterMinigame/singularityBegin.png")
@onready var hoverTexture:Texture = preload("res://assets/2d/shooterMinigame/singularityHover.png")

@onready var spiderRobot:PackedScene = preload("res://objects/spiderRobot.tscn")
@onready var slimeRobot:PackedScene = preload("res://objects/slimeRobot.tscn")
@onready var droneRobot:PackedScene = preload("res://objects/droneRobot.tscn")
@onready var motherfish:PackedScene = preload("res://objects/motherfish.tscn")
@onready var corruptBullet:PackedScene = preload("res://objects/enemyBulletCorrupt.tscn")

func corrupt():
	$arenaTilemap.visible = false
	$corruptArena.visible = true
	$HUD/beginButton/keybinds.visible = false
	corrupted = true
	
	brokenHeartTexture = load("res://assets/2d/shooterMinigame/heartBrokenCorrupt.png")
	fullHeartTexture = load("res://assets/2d/shooterMinigame/heartFullCorrupt.png")
	beginTexture = load("res://assets/2d/shooterMinigame/fateBegin.png")
	hoverTexture = load("res://assets/2d/shooterMinigame/fateHover.png")
	$HUD/beginButton.texture = load("res://assets/2d/shooterMinigame/fateBegin.png")
	$player/sprite.texture = load("res://assets/2d/shooterMinigame/playerCorrupt.png")
	$HUD/heartC.texture = fullHeartTexture
	$HUD/heartB.texture = fullHeartTexture
	$HUD/heartA.texture = fullHeartTexture
	$HUD/heartA/heartPulsate.play("pulsate")
	$HUD/heartB/heartPulsate.play("pulsate")
	$HUD/heartC/heartPulsate.play("pulsate")
	$corruptGame.play("corrupt")
	
	$player.bulletScene = load("res://objects/bulletCorrupt.tscn")
	spiderRobot = load("res://objects/spiderRobotCorrupt.tscn")
	slimeRobot = load("res://objects/slimeRobotCorrupt.tscn")
	droneRobot = load("res://objects/droneRobotCorrupt.tscn")
	motherfish = load("res://objects/motherfishCorrupt.tscn")

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
	timeSinceStarted = 120.0 if corrupted else 0.0
	_on_spawn_timer_timeout()

func _process(delta):
	if !GI.shooterActive: return;
	timeSinceStarted += delta

func playerHealed():
	$player/heal.play()
	if playerHealth >= 3:
		score += 500
		return
	playerHealth += 1
	match playerHealth:
		3: $HUD/heartC.texture = fullHeartTexture;
		2: $HUD/heartB.texture = fullHeartTexture;
		1: $HUD/heartA.texture = fullHeartTexture;

func _on_player_damage():
	if playerHealth > 0: playerHealth -= 1;
	match playerHealth:
		2:
			$HUD/heartC.texture = brokenHeartTexture
			$player/hit.play()
		1:
			$HUD/heartB.texture = brokenHeartTexture
			$player/hit.play()
		0:
			$HUD/heartA.texture = brokenHeartTexture
			$player.alive = false
			$spawnTimer.stop()
			$HUD/beginButton.visible = true
			$player.visible = false
			$HUD/beginButton/interact/hitbox.set_deferred("disabled", false)
			$player/die.play()
			if score == 0: $HUD/beginButton/score.text = "";
			else: $HUD/beginButton/score.text = "Score: " + str(score);
			var previousSFXVolume:int = GI.sfxVolume
			GI.sfxVolume = 0
			while len(allEnemies) > 0:
				var nextEnemy = allEnemies.pop_front()
				if nextEnemy != null: nextEnemy.kill()
			GI.sfxVolume = previousSFXVolume
			if laplaceDescended:
				laplaceDescended = false
				$laplace/laplaceBulletTimer.stop()
				$laplace/shotContinuousSFX.stop()
				$corruptGame.play("laplaceAscend")

func _on_spawn_timer_timeout():
	if !$player.alive: return;
	if timeSinceStarted > 210.0 and corrupted:
		var previousSFXVolume:int = GI.sfxVolume
		GI.sfxVolume = 0
		while len(allEnemies) > 0:
			var nextEnemy = allEnemies.pop_front()
			if nextEnemy != null: nextEnemy.kill()
		GI.sfxVolume = previousSFXVolume
		$corruptGame.play("laplaceDescend")
		emit_signal("laplaceSpawned")
		laplaceDescended = true
		return
	
	$spawnTimer.wait_time = STARTING_SPAWN_TIME * pow(0.995, timeSinceStarted + 1.0)
	if randf() > 0.98:
		var newDrone:Node = droneRobot.instantiate()
		add_child(newDrone)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newDrone.position = chosenSpawnpoint.global_position
		newDrone.velocity = Vector2(newDrone.SPEED, 0).rotated(newDrone.position.angle_to_point(
				chosenSpawnpoint.get_node("activationPoint").global_position))
		newDrone.heal.connect(playerHealed)
		allEnemies.append(newDrone)
	elif randf() > 0.95 and timeSinceStarted > 60.0:
		var newBoss:Node = motherfish.instantiate()
		allEnemies.append(newBoss)
		add_child(newBoss)
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		var moveAngle:float = chosenSpawnpoint.global_position.angle_to_point(
			chosenSpawnpoint.get_node("activationPoint").global_position)
		newBoss.position = chosenSpawnpoint.global_position - Vector2(100, 0).rotated(moveAngle)
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
		newRobot.position = chosenSpawnpoint.global_position
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newRobot, "position", chosenSpawnpoint.get_node("activationPoint").global_position, 0.5)
		spawnTween.tween_callback(newRobot.activate)
	$spawnTimer.start()

func _on_laplace_bullet_timer_timeout():
	if !$player.alive: return;
	if $laplace/laplaceBulletTimer.wait_time > 0.3:
		$laplace/shotSFX.play()
	elif !$laplace/shotContinuousSFX.is_playing():
		$laplace/shotContinuousSFX.play()
	if $laplace/laplaceBulletTimer.wait_time > 0.05:
		$laplace/laplaceBulletTimer.wait_time *= 0.95
	else:
		laplaceBulletSpeed += 0.0025
	$laplace/bulletPivot.look_at(GI.playerPos2D)
	for dir in $laplace/bulletPivot.get_children():
		var newBullet:Node = corruptBullet.instantiate()
		add_child(newBullet)
		allEnemies.append(newBullet)
		newBullet.position = $laplace/bulletPivot.global_position
		newBullet.direction = Vector2(laplaceBulletSpeed, 0).rotated(
			newBullet.position.angle_to_point(dir.global_position))

func toggleLaplaceBullets(enable:bool) -> void:
	$laplace/laplaceBulletTimer.wait_time = 1.0
	laplaceBulletSpeed = 1.0
	if enable: $laplace/laplaceBulletTimer.start();
	else: $laplace/laplaceBulletTimer.stop();

func killGame() -> void:
	playerHealth = 0
	$HUD/heartA.texture = brokenHeartTexture
	$HUD/heartB.texture = brokenHeartTexture
	$HUD/heartC.texture = brokenHeartTexture
	$player.alive = false
	$spawnTimer.stop()
	$HUD/beginButton.visible = true
	$player.visible = false
	$HUD/beginButton/interact/hitbox.set_deferred("disabled", false)
	if score == 0: $HUD/beginButton/score.text = "";
	else: $HUD/beginButton/score.text = "Score: " + str(score);
	var previousSFXVolume:int = GI.sfxVolume
	GI.sfxVolume = 0
	while len(allEnemies) > 0:
		var nextEnemy = allEnemies.pop_front()
		if nextEnemy != null: nextEnemy.kill()
	GI.sfxVolume = previousSFXVolume
	if laplaceDescended:
		$laplace/laplaceBulletTimer.stop()
		$laplace/shotContinuousSFX.stop()
		laplaceDescended = false
		$corruptGame.play("laplaceAscend")
