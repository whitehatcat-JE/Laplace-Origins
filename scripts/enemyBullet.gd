extends Area2D

const SPEED:float = 400.0

var direction:Vector2 = Vector2()
var dead:bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		if !$explosionParticles.emitting: queue_free();
	position += direction * delta * SPEED

func kill():
	$explosionParticles.emitting = true
	$sprite.visible = false
	$hitbox.set_deferred("disabled", true)

func _on_decay_timer_timeout():
	kill()

func _on_body_entered(body):
	kill()

func _on_area_entered(area):
	area.kill()
	kill()
