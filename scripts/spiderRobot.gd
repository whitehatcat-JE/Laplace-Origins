extends CharacterBody2D
# Constants (Including variables assigned during spawn-in)
@export var MAX_HEALTH:int = 4
var SPEED:float = 100.0 * randf_range(0.9, 1.1)
# State variables
var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false
# Health bar size
@onready var maxHealthSize:float = $health.size.x
# Move self and delete self after death animation
func _physics_process(delta) -> void:
	if !active: return;
	if dead: # Delete self if death animation finished
		if !$explosionParticles.emitting: queue_free();
		return
	# Moves self towards player
	velocity = Vector2(SPEED, 0).rotated(position.angle_to_point(GI.playerPos2D))
	move_and_slide()
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
# Damage self if collide with bullet
func _on_bullet_scanner_area_entered(area) -> void:
	area.kill() # Destroy bullet
	# Damage self
	health -= 1
	$health.visible = true
	if health == 0: # Trigger death event
		get_parent().score += 25
		kill()
	$health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH)
