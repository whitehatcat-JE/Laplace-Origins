extends CharacterBody2D
# Constants
const MAX_HEALTH:int = 6
# State variables
var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false

@onready var maxHealthSize:float = $sprite/health.size.x # Health bar width
@onready var bullet:PackedScene = preload("res://objects/enemyBullet.tscn") # Bullet object
# Disables collisions after 1 frame, to avoid false player collisions on spawn-in
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)
# Ensures bullets fire towards player, and deletes self after death animation complete
func _physics_process(delta) -> void:
	if dead and !$explosionParticles.emitting and !$die.is_playing(): queue_free();
	$bulletPivot.look_at(GI.playerPos2D)
# Kills self
func kill() -> void:
	# Deactivates self
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	$bulletTimer.stop()
	# Plays death animation
	$explosionParticles.emitting = true
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.play()
# Starts bullet firing sequence
func activate() -> void: $bulletTimer.start();
# Damages self on bullet collision
func _on_bullet_scanner_area_entered(area) -> void:
	area.kill() # Destroys colliding bullet
	health -= 1
	$sprite/health.visible = true
	if health == 0: # Triggers death sequence if health equals 0
		get_parent().score += 750
		kill()
	# Update displayed health
	$sprite/health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH)
# Creates and returns new bullet instance
func createBullet() -> Node:
	var newBullet:Node = bullet.instantiate()
	get_parent().add_child(newBullet)
	get_parent().allEnemies.append(newBullet)
	newBullet.position = $bulletPivot.global_position
	return newBullet
# Applies directional velocity to given bullet instance
func applyVelocity(subject, targetDir) -> void:
	subject.direction = Vector2(1, 0).rotated(
		subject.position.angle_to_point(targetDir))
# Triggers next bullet attack phase
func _on_bullet_timer_timeout() -> void:
	if dead: return;
	# Plays shoot audio
	$shot.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$shot.play()
	if randf_range(0, 1) < 0.33: # Fires bullets in all directions
		$bulletPivot.rotation_degrees = 0.0
		for dir in $bulletPivot.get_children():
			applyVelocity(createBullet(), dir.global_position)
		return
	$bulletPivot.look_at(GI.playerPos2D)
	if randf_range(0, 1) < 0.5: # Fires 3 bullets around player direction
		applyVelocity(createBullet(), $bulletPivot/nTarget.global_position)
		applyVelocity(createBullet(), $bulletPivot/neTarget.global_position)
		applyVelocity(createBullet(), $bulletPivot/nwTarget.global_position)
	else: # Fires 3 bullets directly at player
		for bulletNum in range(3):
			if dead: return;
			applyVelocity(createBullet(), $bulletPivot/nTarget.global_position)
			await get_tree().create_timer(0.1).timeout
