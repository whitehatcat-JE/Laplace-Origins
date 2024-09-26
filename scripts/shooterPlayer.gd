extends CharacterBody2D
# Signals
signal damage
# Constants
const SPEED:float = 200.0
const FIRING_SPEED:float = 0.2
# State variables
var timeSinceLastBullet:float = 0.0
var alive:bool = false
# Bullet object
@onready var bulletScene:PackedScene = preload("res://objects/bullet.tscn")
# Spawn bullet in direction player shooting
func spawnBullet() -> void:
	# Calculate firing direction
	var dir:Vector2 = Input.get_vector("shooterFireLeft", "shooterFireRight", "shooterFireUp", "shooterFireDown")
	if dir.is_zero_approx(): return;
	# Spawn bullet instance
	var bullet:Node = bulletScene.instantiate()
	get_parent().add_child(bullet)
	# Move bullet in firing direction
	bullet.position = position
	bullet.direction = dir
	bullet.collision_layer = 16

# Player movement and shoot detection
func _physics_process(delta) -> void:
	if !GI.shooterActive or !GI.inOS or !alive: return; # Stop player from moving if game not focused or player dead
	# Bullet fire cooldown
	timeSinceLastBullet += delta
	# Move in inputted direction
	velocity = Input.get_vector("shooterMoveLeft", "shooterMoveRight", "shooterMoveUp", "shooterMoveDown") * SPEED
	move_and_slide()
	# Update globally stored player position, for enemy A.I accecss
	GI.playerPos2D = position
	# Check if player is firing bullet
	if (Input.is_action_pressed("shooterFireLeft") or
		Input.is_action_pressed("shooterFireRight") or
		Input.is_action_pressed("shooterFireUp") or
		Input.is_action_pressed("shooterFireDown")) and timeSinceLastBullet > FIRING_SPEED:
		timeSinceLastBullet = 0.0
		spawnBullet() # Fire bullet
# Detect player-enemy collision
func _on_enemy_scanner_body_entered(body) -> void:
	if !alive or body.dead: return;
	body.kill() # Destroy enemy
	emit_signal("damage") # Damage player
# Detect player-enemyBullet collision
func _on_enemy_scanner_area_entered(area) -> void:
	if !alive: return;
	area.kill() # Destroy bullet
	emit_signal("damage") # Damage player
