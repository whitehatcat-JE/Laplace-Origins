extends Node3D
# Nodes
@onready var enviro:Node = $worldEnvironment
# Applies settings during scene spawn-in
func _ready() -> void:
	GI.fromOutside = true
	$player/head/cam.rotation_degrees.x = 0.0
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfx.volume_db = sfx.volume_db - (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	if GI.graphics == "Low":
		enviro.get_environment().set_sdfgi_enabled(false)
		enviro.get_environment().set_ssil_enabled(false)
		enviro.get_environment().set_ssao_enabled(false)
		enviro.get_environment().set_volumetric_fog_enabled(false)
	if GI.previousScreen != null: GI.previousScreen.call_deferred("free"); # Clears home scene cache
	$player/HUD/fadeAnim.play("fade")
	$player/menu.disabled = true
	await $player/HUD/fadeAnim.animation_finished
	$player/menu.disabled = false
# Play outdoor intro animation
func playOutdoors():
	$audioManager.play("outdoor", 3.0)
	$audioManager/outdoorDistorted.play()
# Play laplace panoramic animation (Ending animation)
func _on_reveal_trigger_body_entered(body) -> void:
	$player.disabled = true
	$player/menu.disabled = true
	if GI.steamLoaded: Steam.setAchievement("SH_COMPLETEGAME");
	# Rotates player to face laplace
	var tween:Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($player, "rotation_degrees", Vector3(0.0, 130.0, 0.0), 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property($player/head/cam, "rotation_degrees", Vector3(-40.0, 0.0, 0.0), 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await tween.finished
	$player/lookUpAnim.play("lookUp")
# Restarts game once ending played
func _on_look_up_anim_animation_finished(anim_name) -> void:
	GI.progress = 0
	GI.hasFreeKey = false
	GI.pianoDoorUnlocked = false
	GI.freeDownloaded = false
	get_tree().change_scene_to_file("res://scenes/space.tscn")
# Glitch out music
func corruptMusic():
	if GI.musicVolume == 0: return;
	var musicTween:Tween = get_tree().create_tween()
	musicTween.tween_property($audioManager/outdoor, "volume_db", -20, 12.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	musicTween.parallel().tween_property($audioManager/outdoorDistorted, "volume_db", -25 + GI.musicVolume * 2, 12.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	musicTween.tween_property($audioManager/outdoor, "playing", false, 0.1)
	musicTween.tween_interval(4.0)
	musicTween.parallel().tween_property($audioManager/outdoorDistorted, "volume_db", -80, 12.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
