extends Node3D

func _on_reveal_trigger_body_entered(body):
	$player.disabled = true
	$player/lookUpAnim.play("camLookUp")
	
	var tween = get_tree().create_tween()
	tween.tween_property($player, "rotation_degrees", Vector3(0.0, 90.0, 0.0), 1).set_trans(Tween.TRANS_SINE)
