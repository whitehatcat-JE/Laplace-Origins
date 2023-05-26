extends Node3D

func _on_reveal_trigger_body_entered(body):
	$player.disabled = true
	$player/lookUpAnim.play("camLookUp")
	
	var tween = get_tree().create_tween()
	tween.tween_property($player, "rotation_degrees", Vector3(0.0, 90.0, 0.0), 1).set_trans(Tween.TRANS_SINE)


func _on_look_up_anim_animation_finished(anim_name):
	GI.progress = 0
	get_tree().change_scene_to_file("res://scenes/home.tscn")
