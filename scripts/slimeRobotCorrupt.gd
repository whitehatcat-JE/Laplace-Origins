extends CharacterBody2D
# Constants (Including variables assigned during spawn-in)
const MAX_HEALTH:int = 3
const DRAG:float = 4.0
var JUMP_SPEED:float = 300.0 * randf_range(0.9, 1.1)
# State variables
var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false
# Health bar size
@onready var maxHealthSize:float = $health.size.x
# Baby slime object
@onready var babySlime:PackedScene = preload("res://objects/babySlimeRobotCorrupt.tscn")
# Spawn baby slime instance
func spawnBaby() -> void:
	# Create instance
	var newBaby:Node = babySlime.instantiate()
	# Append instance to parent
	get_parent().add_child(newBaby)
	get_parent().allEnemies.append(newBaby)
	# Position and activate instance
	newBaby.position = position
	newBaby.activate()
# Move self and delete self after death animation
func _physics_process(delta) -> void:
	if !active: return;
	if dead: # Delete self if death animation finished
		if !$explosionParticles.emitting: queue_free();
		return
	if velocity.length() < 10.0: # Apply velocity impulse if velocity reaches threshold
		velocity = Vector2(JUMP_SPEED, 0).rotated(randf_range(-PI, PI))
	velocity -= velocity * delta * DRAG # Apply drag to velocity
	move_and_slide() # Move self in velocity direction and magnitude
# Destroys self
func kill() -> void:
	# Deactivates self
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	$health.visible = false
	# Plays death animation
	$explosionParticles.emitting = true
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.pitch_scale *= randf_range(0.8, 1.2)
	$die.play()
# Activates self
func activate() -> void:
	active = true
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)
	$babySpawnTimer.start()
# Damage self if collide with bullet
func _on_bullet_scanner_area_entered(area) -> void:
	area.kill() # Destroy bullet
	# Damage self
	health -= 1
	$health.visible = true
	if health == 0: # Trigger death event
		get_parent().score += 100
		kill()
	$health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH) # Update health bar
# Spawn baby slime after cooldown
func _on_baby_spawn_timer_timeout() -> void:
	if !dead: spawnBaby();
