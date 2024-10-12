extends Node3D

var homeScene = null
var animStarted:bool = true

var appID:String = "2841470"

func _init():
	OS.set_environment("SteamAppID", appID)
	OS.set_environment("SteamGameID", appID)

func _ready() -> void:
	Steam.steamInit()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$audioManager.play("title")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and !animStarted:
		animStarted = true
		$introAnim.play("intro")
		$menu.disabled = true
		var fadeTween := get_tree().create_tween()
		fadeTween.tween_property($audioManager/title, "volume_db", -80, 6.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await $introAnim.animation_finished

func startLoadingHome():
	homeScene = ResourceLoader.load_threaded_request("res://scenes/home.tscn")
	loadHome()

func loadHome():
	await get_tree().create_timer(0.1).timeout
	match ResourceLoader.load_threaded_get_status("res://scenes/home.tscn"):
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			$introAnim.play("complete")
			$completeBell.play()
			var fadeTween := get_tree().create_tween()
			fadeTween.tween_property($crtTurnOn, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
			await $introAnim.animation_finished
			homeScene = ResourceLoader.load_threaded_get("res://scenes/home.tscn")
			print(homeScene)
			get_tree().change_scene_to_packed(homeScene)
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			get_tree().change_scene_to_file("res://scenes/home.tscn")
			return
	loadHome()

func allowIntro():
	animStarted = false
