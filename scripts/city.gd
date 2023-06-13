extends Node3D
# Plays city SFX when scene loaded
func _ready() -> void:
	$cityAmbience.volume_db = $cityAmbience.volume_db - (10 - GI.musicVolume) * 2 if GI.musicVolume > 0 else -80
	$player/footstepsGravel.volume_db = $player/footstepsGravel.volume_db - ((10 - GI.sfxVolume) * 2) if GI.sfxVolume > 0 else -80
# Teleports player to basement
func _on_city_trigger_field_body_entered(_body) -> void:
	$cityTriggerField.set_deferred("monitoring", false)
	# Deletes city scene
	var root:Node = get_node("/root")
	var cityScene:Node = get_node("/root/city")
	root.call_deferred("remove_child", cityScene)
	cityScene.call_deferred("free")
	# Loads basement scene
	var homeScene:Node = GI.previousScreen
	root.add_child(homeScene)
	homeScene.playerCam.current = true
# Activates basement teleporter
func _on_activate_city_trigger_field_body_exited(_body) -> void:
	$cityTriggerField.set_deferred("monitoring", true)
# Teleports player back to basement after kneel animation complete
func _on_kneel_anim_animation_finished(_anim_name) -> void:
	_on_city_trigger_field_body_entered(null)
# Triggers kneel animation once player walks off cliff
func _on_kneel_trigger_field_body_entered(_body) -> void:
	$player.disabled = true
	$kneelAnim.play("kneel")
