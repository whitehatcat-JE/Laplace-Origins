extends Node2D

var speed:float = 1.0

func _process(delta):
	position.x -= speed * delta
	if position.x < -500.0:
		queue_free()
