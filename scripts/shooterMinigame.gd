extends Node2D
# Signals
signal laplaceSpawned
# Constants
const STARTING_HEALTH:int = 3
const STARTING_SPAWN_TIME:float = 2.5
# State variables
var playerHealth:int = STARTING_HEALTH
var timeSinceStarted:float = 0.0

var allEnemies:Array[Node] = []
var score:int = 0
var timeSinceLastMother:int = 0

var corrupted:bool = false
var laplaceDescended:bool = false
var laplaceBulletSpeed = 1.0

var healingDroneChance:float = 0.98

# Textures
@onready var brokenHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartBroken.png")
@onready var fullHeartTexture:Texture = preload("res://assets/2d/shooterMinigame/heartFull.png")
@onready var beginTexture:Texture = preload("res://assets/2d/shooterMinigame/singularityBegin.png")
@onready var hoverTexture:Texture = preload("res://assets/2d/shooterMinigame/singularityHover.png")
# Enemy objects
@onready var spiderRobot:PackedScene = preload("res://objects/spiderRobot.tscn")
@onready var slimeRobot:PackedScene = preload("res://objects/slimeRobot.tscn")
@onready var droneRobot:PackedScene = preload("res://objects/droneRobot.tscn")
@onready var motherfish:PackedScene = preload("res://objects/motherfish.tscn")
@onready var corruptBullet:PackedScene = preload("res://objects/enemyBulletCorrupt.tscn")
# Change game from singularity to fate
func corrupt():
	$arenaTilemap.visible = false
	$corruptArena.visible = true
	$HUD/beginButton/keybinds.visible = false
	corrupted = true
	# Swap assets
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
	# Swap enemies
	$player.bulletScene = load("res://objects/bulletCorrupt.tscn")
	spiderRobot = load("res://objects/spiderRobotCorrupt.tscn")
	slimeRobot = load("res://objects/slimeRobotCorrupt.tscn")
	droneRobot = load("res://objects/droneRobotCorrupt.tscn")
	motherfish = load("res://objects/motherfishCorrupt.tscn")
	
	healingDroneChance = 0.9
# Enter / exit shooter minigame
func start(): GI.shooterActive = true;
func stop(): GI.shooterActive = false;
# Start round of minigame
func begin():
	for hID in "ABC": get_node("HUD/heart" + hID).texture = fullHeartTexture; # Reset heart textures
	score = 0 # Reset score
	# Reset player
	playerHealth = STARTING_HEALTH
	$player.visible = true
	$player.alive = true
	$player.position = Vector2(1053, 353)
	# Disable menu
	$HUD/beginButton.visible = false
	$HUD/beginButton/interact/hitbox.set_deferred("disabled", true)
	# Start timers
	timeSinceStarted = 60.0 if corrupted else 0.0
	_on_spawn_timer_timeout()
# Increase round time if game active
func _process(delta):
	if !GI.shooterActive: return;
	timeSinceStarted += delta
# Heal player
func playerHealed():
	$player/heal.play()
	if playerHealth >= 3: # Increase score by 500 instead if player at max health
		score += 500
		return
	playerHealth += 1
	get_node("HUD/heart" + "ABC"[playerHealth - 1]).texture = fullHeartTexture;
# Damage player
func _on_player_damage():
	if playerHealth > 0: playerHealth -= 1;
	match playerHealth: # Update game with new health
		2:
			$HUD/heartC.texture = brokenHeartTexture
			$player/hit.play()
		1:
			$HUD/heartB.texture = brokenHeartTexture
			$player/hit.play()
		0: # Player death
			$HUD/heartA.texture = brokenHeartTexture
			# Stop player
			$player.alive = false
			$spawnTimer.stop()
			$player.visible = false
			$player/die.play()
			# Kill all entities
			var previousSFXVolume:int = GI.sfxVolume
			GI.sfxVolume = 0
			while len(allEnemies) > 0:
				var nextEnemy = allEnemies.pop_front()
				if nextEnemy != null: nextEnemy.kill();
			GI.sfxVolume = previousSFXVolume
			# Withdraw laplace
			if laplaceDescended:
				laplaceDescended = false
				$laplace/laplaceBulletTimer.stop()
				$laplace/shotContinuousSFX.stop()
				$corruptGame.play("laplaceAscend")
			# Show menu
			$HUD/beginButton.visible = true
			$HUD/beginButton/interact/hitbox.set_deferred("disabled", false)
			# Show score
			if score == 0: $HUD/beginButton/score.text = "";
			else: $HUD/beginButton/score.text = "Score: " + str(score);
# Spawn new enemy
func _on_spawn_timer_timeout():
	if !$player.alive: return;
	if timeSinceStarted > 115.0 and corrupted: # Spawn laplace
		var previousSFXVolume:int = GI.sfxVolume
		GI.sfxVolume = 0
		while len(allEnemies) > 0:
			var nextEnemy = allEnemies.pop_front()
			if nextEnemy != null: nextEnemy.kill();
		GI.sfxVolume = previousSFXVolume
		$corruptGame.play("laplaceDescend")
		emit_signal("laplaceSpawned")
		laplaceDescended = true
		return
	timeSinceLastMother += 1
	# Decrease spawn time for next enemy
	$spawnTimer.wait_time = STARTING_SPAWN_TIME * pow(0.99, timeSinceStarted + 1.0)
	if randf() > healingDroneChance: # Spawn healer drone
		var newDrone:Node = droneRobot.instantiate()
		# Append drone to self
		add_child(newDrone)
		allEnemies.append(newDrone)
		# Position drone
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newDrone.position = chosenSpawnpoint.global_position
		newDrone.velocity = Vector2(newDrone.SPEED, 0).rotated(newDrone.position.angle_to_point(
				chosenSpawnpoint.get_node("activationPoint").global_position))
		# Connect drone to self
		newDrone.heal.connect(playerHealed)
	elif randf() > 0.95 and timeSinceStarted > 60.0 and timeSinceLastMother > 8: # Spawn motherfish
		timeSinceLastMother = 0
		var newBoss:Node = motherfish.instantiate()
		# Append motherfish to self
		allEnemies.append(newBoss)
		add_child(newBoss)
		# Position motherfish
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		var moveAngle:float = chosenSpawnpoint.global_position.angle_to_point(
			chosenSpawnpoint.get_node("activationPoint").global_position)
		newBoss.position = chosenSpawnpoint.global_position - Vector2(100, 0).rotated(moveAngle)
		# Motherfish spawn animation
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newBoss, "position", 
			chosenSpawnpoint.get_node("activationPoint").global_position + Vector2(
				100 * randf_range(0.8, 1.5), 0).rotated(moveAngle), 7)
		spawnTween.tween_callback(newBoss.activate)
	else: # Spawn spider or slime robot
		var newRobot:Node = spiderRobot.instantiate() if randf() > 0.2 or timeSinceStarted < 20.0 else slimeRobot.instantiate()
		# Append robot to self
		allEnemies.append(newRobot)
		add_child(newRobot)
		# Position robot
		var chosenSpawnpoint:Node = $spawnpoints.get_child(randi_range(0, 12))
		newRobot.position = chosenSpawnpoint.global_position
		# Robot spawn animation
		var spawnTween:Tween = get_tree().create_tween()
		spawnTween.tween_property(newRobot, "position", chosenSpawnpoint.get_node("activationPoint").global_position, 0.5)
		spawnTween.tween_callback(newRobot.activate)
	$spawnTimer.start() # Restarts spawn timer for next enemy
# Make laplace fire bullet
func _on_laplace_bullet_timer_timeout():
	if !$player.alive: return;
	# Increase firing speed
	if $laplace/laplaceBulletTimer.wait_time > 0.3: $laplace/shotSFX.play();
	elif !$laplace/shotContinuousSFX.is_playing(): $laplace/shotContinuousSFX.play();
	if $laplace/laplaceBulletTimer.wait_time > 0.05: $laplace/laplaceBulletTimer.wait_time *= 0.95;
	else: laplaceBulletSpeed += 0.0025;
	# Fire bullet in all directions, with north bullet angled towards player
	$laplace/bulletPivot.look_at(GI.playerPos2D)
	for dir in $laplace/bulletPivot.get_children():
		var newBullet:Node = corruptBullet.instantiate()
		add_child(newBullet)
		allEnemies.append(newBullet)
		newBullet.position = $laplace/bulletPivot.global_position
		newBullet.direction = Vector2(laplaceBulletSpeed, 0).rotated(
			newBullet.position.angle_to_point(dir.global_position))
# Enable / disable laplace bullet firing
func toggleLaplaceBullets(enable:bool) -> void:
	$laplace/laplaceBulletTimer.wait_time = 1.0
	laplaceBulletSpeed = 1.0
	if enable: $laplace/laplaceBulletTimer.start();
	else: $laplace/laplaceBulletTimer.stop();
# Kill game instantly
func killGame() -> void:
	# Reduce player health
	playerHealth = 0
	for hID in "ABC": get_node("HUD/heart" + hID).texture = brokenHeartTexture;
	# Disable player
	$player.alive = false
	$player.visible = false
	# Disable enemy spawning
	$spawnTimer.stop()
	# Show menu
	$HUD/beginButton.visible = true
	$HUD/beginButton/interact/hitbox.set_deferred("disabled", false)
	# Update score
	if score == 0: $HUD/beginButton/score.text = "";
	else: $HUD/beginButton/score.text = "Score: " + str(score);
	# Kill entities
	var previousSFXVolume:int = GI.sfxVolume
	GI.sfxVolume = 0
	while len(allEnemies) > 0:
		var nextEnemy = allEnemies.pop_front()
		if nextEnemy != null: nextEnemy.kill();
	GI.sfxVolume = previousSFXVolume
	# Withdraw laplace
	if laplaceDescended:
		$laplace/laplaceBulletTimer.stop()
		$laplace/shotContinuousSFX.stop()
		laplaceDescended = false
		$corruptGame.play("laplaceAscend")
