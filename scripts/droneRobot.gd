extends CharacterBody2D
# Heal player
signal heal
# Flight speed
@export var SPEED:float = 150.0
# State variables
var dead:bool = false
# Moves self in flight direction
func _physics_process(delta) -> void:
	if dead: # Deletes self once death animation complete
		if !$explosionParticles.emitting and !$healParticles.emitting: queue_free();
		return
	move_and_slide()
# Kills self
func kill() -> void:
	# Deactives self
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	dead = true
	# Plays death animation
	$explosionParticles.emitting = true
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.play()
# Destroys self on bullet collision
func _on_bullet_scanner_area_entered(area) -> void:
	# Plays death animation
	$healParticles.emitting = true
	# Deactivates self
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	dead = true
	
	get_parent().score += 500 # Increases player score
	emit_signal("heal") # Heals player
# Destroys self once offscreen
func _on_decay_timer_timeout() -> void: queue_free();
