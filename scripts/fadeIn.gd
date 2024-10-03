extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	$"../menu".disabled = true
	var crtTween = get_tree().create_tween()
	crtTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	crtTween.set_parallel(true)
	crtTween.tween_property($crtFade, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/warp_amount", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/resolution", Vector2(1920, 1080), 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/scanlines_opacity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/grille_opacity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/noise_opacity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/distort_intensity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/vignette_intensity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/brightness", 1, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/aberration", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/static_noise_intensity", 0.0, 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.set_parallel(false)
	crtTween.tween_property($crt, "visible", false, 0.01)
	await crtTween.finished
	get_tree().paused = false
	$"../menu".disabled = false
