extends Node3D

var story:int = 1
var nextDimensionQueued:bool = false
var dimensionNum:int = 1

func _ready():
	$dimension2.position.y = -100
	$dimension3.position.y = -100
	$dimension3.visible = false
	$dimension4.visible = false

func _on_dimension_1_transition_boundary_screen_exited():
	print("aaaa")
	if nextDimensionQueued and dimensionNum == 1:
		dimensionNum = 2
		nextDimensionQueued = false
		$dimension1/doorway.visible = false
		$dimension2.position.y = 0
	elif dimensionNum >= 2 and $player.position.z < 5 and story == 1:
		$player.position.z += randf_range(1.0, 15.0)
		

func _on_dimension_1_seen_boundary_screen_entered():
	if dimensionNum == 1:
		nextDimensionQueued = true

func _on_dimension_2_transition_boundary_screen_exited():
	if dimensionNum == 2 and story == 2:
		dimensionNum = 3
		$dimension3.position.y = 0

func _on_first_story_entrance_field_body_entered(body):
	story = 1
	$dimension3.visible = false

func _on_second_story_entrance_field_body_entered(body):
	story = 2
	$dimension3.visible = true


func _on_third_story_entrance_field_body_entered(body):
	$dimension4.visible = false


func _on_forth_story_entrance_field_body_entered(body):
	$dimension4.visible = true
