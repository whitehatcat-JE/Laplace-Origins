extends Node2D
# State variables
var speed:float = 1.0
# Increment pillar position
func _process(delta):
	position.x -= speed * delta
	if position.x < -500.0: queue_free();
