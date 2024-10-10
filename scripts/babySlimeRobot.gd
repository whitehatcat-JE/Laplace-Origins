extends CharacterBody2D
# Constants
const MAX_HEALTH:int = 1
const DRAG:float = 4.0
# Speed constant randomized for slight individuality
var JUMP_SPEED:float = 150.0 * randf_range(0.9, 1.1)
# State variables
var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false
# Moves self and checks if needs to be deleted
func _physics_process(delta) -> void:
	if !active: return; # Stops self from moving before spawned in
	if dead: # Deletes self if death animation complete
		if !$explosionParticles.emitting: queue_free();
		return
	if velocity.length() < 10.0: # Updates movement direction
		velocity = Vector2(JUMP_SPEED, 0).rotated(position.angle_to_point(GI.playerPos2D))
	# Moves self in current direction
	velocity -= velocity * delta * DRAG
	move_and_slide()
# Kills self
func kill() -> void:
	# Deactivates self
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	set_collision_layer_value(7, false)
	set_collision_mask_value(1, false)
	$sprite.visible = false
	# Plays death animation
	$explosionParticles.emitting = true
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.pitch_scale *= randf_range(0.8, 1.2)
	$die.play()
# Activates self
func activate() -> void:
	active = true
	await get_tree().create_timer(0.1).timeout # Delay stops self from falsely colliding with player 
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)
# Damages self when hit with bullet
func _on_bullet_scanner_area_entered(area) -> void:
	if area.has_method("kill"):
		area.kill()
		health -= 1
		if health == 0: kill();
