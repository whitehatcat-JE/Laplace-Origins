extends Node3D

func _ready():
	$cityAmbience.volume_db = $cityAmbience.volume_db - (10 - GI.musicVolume) * 2 if GI.musicVolume > 0 else -80
	$player/footstepsGravel.volume_db = $player/footstepsGravel.volume_db - ((10 - GI.sfxVolume) * 2) if GI.sfxVolume > 0 else -80

func _on_city_trigger_field_body_entered(_body):
	$cityTriggerField.set_deferred("monitoring", false)
	var root = get_node("/root")  #need this as get_node will stop work once you remove your self from the Tree
	var cityScene = get_node("/root/city")
	root.call_deferred("remove_child", cityScene)
	cityScene.call_deferred("free")

	var homeScene = GI.previousScreen
	root.add_child(homeScene)
	homeScene.playerCam.current = true


func _on_activate_city_trigger_field_body_exited(body):
	$cityTriggerField.set_deferred("monitoring", true)

func _on_kneel_anim_animation_finished(anim_name):
	_on_city_trigger_field_body_entered(null)

func _on_kneel_trigger_field_body_entered(body):
	$player.disabled = true
	$kneelAnim.play("kneel")
