extends Area2D
# Constants
const SPEED:float = 400.0
# State variables
var direction:Vector2 = Vector2()
var dead:bool = false

# Moves bullet in direction fired
func _process(delta) -> void:
	if dead:
		if !$explosionParticles.emitting: queue_free();
		return
	position += direction * delta * SPEED
# Destroys bullet
func kill() -> void:
	$explosionParticles.emitting = true
	$sprite.visible = false
	$hitbox.set_deferred("disabled", true)
	dead = true

func _on_decay_timer_timeout() -> void: kill(); # Destroys bullet if offscreen
func _on_body_entered(body) -> void: kill(); # Destroys bullet on collision
