extends Node3D

const MAX_DISTANCE_BOTTOM:float = 60.0
const MAX_DISTANCE_TOP:float = 30.0

var story:int = 1
var nextDimensionQueued:bool = false
var dimensionNum:int = 1

func _ready():
	$dimension2.position.y = -100
	$dimension3.visible = false
	$dimension4.visible = false
	$pillars.visible = false

func _process(delta: float) -> void:
	if story == 1:
		if $player.position.distance_to(Vector3(0, $player.position.y, 0.0)) >= MAX_DISTANCE_BOTTOM:
			teleportPlayer()
	elif story == 2:
		if $player.position.distance_to(Vector3(15.0, $player.position.y, 0.0)) >= MAX_DISTANCE_TOP:
			teleportPlayer()

func _on_dimension_1_transition_boundary_screen_exited():
	if nextDimensionQueued and dimensionNum == 1:
		dimensionNum = 2
		nextDimensionQueued = false
		$dimension1/doorway.visible = false
		$dimension2.position.y = 0

func _on_dimension_1_seen_boundary_screen_entered():
	if dimensionNum == 1:
		nextDimensionQueued = true

func _on_show_tower_body_entered(body: Node3D) -> void:
	$dimension3.visible = true
	story = 2

func _on_hide_tower_body_entered(body: Node3D) -> void:
	$dimension3.visible = false
	story = 1

func _on_show_pillars_body_entered(body: Node3D) -> void:
	$pillars.visible = true

func _on_hide_pillars_body_entered(body: Node3D) -> void:
	$pillars.visible = false

func teleportPlayer():
	var img := get_viewport().get_texture().get_image()
	var tex := ImageTexture.create_from_image(img)
	$player/HUD/screenshot.texture = tex
	$player/HUD/hudAnims.play("teleport")
	await RenderingServer.frame_post_draw
	match story:
		1:
			$player.position = $playerBottomRespawnPos.position
		2:
			$player.position = $playerTopRespawnPos.position
