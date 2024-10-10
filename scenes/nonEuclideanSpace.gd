extends Node3D

const MAX_DISTANCE_BOTTOM:float = 60.0
const MAX_DISTANCE_TOP:float = 100.0

var story:int = 1
var nextDimensionQueued:bool = false
var dimensionNum:int = 1

var maxVolume:float = 0

func _ready():
	$dimension2.position.z = 20.0
	$dimension3.position = Vector3(-100, -10, 40)
	changeVolume(-20 + GI.musicVolume * 2)
	$player/menu.disabled = true
	await get_tree().create_timer(0.1).timeout
	$dimension2.position = Vector3(0.0, -100.0, 0.0)
	$dimension3.position = Vector3(0.0, 0.0, 0.0)
	$dimension3.visible = false
	$pillars.visible = false
	$audioManager/nonEuclidean.play()
	$audioManager/nonEuclideanTempo.play()
	if GI.musicVolume > 0:
		var musicTween:Tween = get_tree().create_tween()
		musicTween.tween_property($audioManager/nonEuclidean, "volume_db", $audioManager/nonEuclidean.volume_db, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		$audioManager/nonEuclidean.volume_db = -80
	$player/HUD/hudAnims.play("fadeIn")
	await $player/HUD/hudAnims.animation_finished
	$player/menu.disabled = false

func _process(delta: float) -> void:
	if story == 1:
		if $player.position.distance_to(Vector3(0, $player.position.y, 0.0)) >= MAX_DISTANCE_BOTTOM:
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

func _on_second_story_teleport_fields_body_entered(body: Node3D) -> void:
	teleportPlayer()

func _on_exit_field_body_entered(body: Node3D) -> void:
	$player.disabled = true
	$player/menu.disabled = true
	var fadeOutTween:Tween = get_tree().create_tween()
	fadeOutTween.set_parallel(true)
	fadeOutTween.tween_property($audioManager/nonEuclidean, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	fadeOutTween.tween_property($audioManager/nonEuclideanBass, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	fadeOutTween.tween_property($audioManager/nonEuclideanBell, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	fadeOutTween.tween_property($audioManager/nonEuclideanNoise, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	$player/HUD/hudAnims.play("fadeOut")
	await $player/HUD/hudAnims.animation_finished
	get_tree().change_scene_to_file("res://scenes/outside.tscn")

func _on_non_euclidean_tempo_finished() -> void:
	$audioManager/nonEuclideanTempo.play()
	if randf() > 0.8:
		$audioManager/nonEuclideanBass.play()
	elif randf() > 0.7:
		$audioManager/nonEuclideanBell.play()
	elif randf() > 0.6:
		$audioManager/nonEuclideanNoise.play()

func changeVolume(newVolume:int) -> void:
	if newVolume == -20: newVolume = -80; # Mutes song
	maxVolume = newVolume
	$audioManager/nonEuclidean.volume_db = newVolume
	$audioManager/nonEuclideanBass.volume_db = newVolume
	$audioManager/nonEuclideanBell.volume_db = newVolume
	$audioManager/nonEuclideanNoise.volume_db = newVolume
