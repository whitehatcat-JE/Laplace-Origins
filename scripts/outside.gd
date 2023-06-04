extends Node3D

@onready var enviro:Node = $worldEnvironment

func _ready() -> void:
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfx.volume_db = sfx.volume_db - (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	if GI.graphics == "Low":
		enviro.get_environment().set_sdfgi_enabled(false)
		enviro.get_environment().set_ssil_enabled(false)
		enviro.get_environment().set_ssao_enabled(false)
		enviro.get_environment().set_volumetric_fog_enabled(false)
	$player/HUD/fadeAnim.play("fade")
	if GI.previousScreen != null:
		GI.previousScreen.call_deferred("free")

func playOutdoors():
	if GI.musicVolume == 0: return;
	$outdoor.play()
	var tween:Tween = get_tree().create_tween()
	tween.tween_property($outdoor, "volume_db", -(10 - GI.musicVolume) * 2, 2).set_trans(Tween.TRANS_SINE)

func _on_reveal_trigger_body_entered(body) -> void:
	$player.disabled = true
	$player/lookUpAnim.play("camLookUp" + str(GI.musicVolume))
	
	var tween:Tween = get_tree().create_tween()
	tween.tween_property($player, "rotation_degrees", Vector3(0.0, 90.0, 0.0), 1).set_trans(Tween.TRANS_SINE)

func _on_look_up_anim_animation_finished(anim_name) -> void:
	GI.progress = 0
	get_tree().change_scene_to_file("res://scenes/home.tscn")
