extends Area2D
# Constants
const SPEED:float = 400.0
# State variables
var direction:Vector2 = Vector2()
var dead:bool = false
# Updates position / death state
func _process(delta) -> void:
	if dead: # Deletes self if death animation complete
		if !$explosionParticles.emitting: queue_free();
		return
	position += direction * delta * SPEED # Moves self in assigned direction
# Kills self
func kill() -> void:
	$explosionParticles.emitting = true # Plays death animation
	# Deactivates self
	$sprite.visible = false
	$hitbox.set_deferred("disabled", true)
	dead = true

func _on_decay_timer_timeout() -> void: kill(); # Destroys self if offscreen
func _on_body_entered(_body) -> void: kill(); # Destroys self on wall collision
# Hurt player and destroy self on player collision
func _on_area_entered(area) -> void:
	area.kill()
	kill()
