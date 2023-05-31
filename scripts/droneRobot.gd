extends CharacterBody2D

signal heal

var SPEED:float = 150.0 * randf_range(0.9, 1.1)
var dead:bool = false

func _physics_process(delta):
	if dead:
		if !$explosionParticles.emitting and !$healParticles.emitting: queue_free();
	move_and_slide()

func kill():
	$explosionParticles.emitting = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false

func _on_bullet_scanner_area_entered(area):
	$healParticles.emitting = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	emit_signal("heal")

func _on_decay_timer_timeout():
	queue_free()
