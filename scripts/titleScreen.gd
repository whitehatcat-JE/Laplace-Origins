extends Node3D

var homeScene = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		$introAnim.play("intro")
		await $introAnim.animation_finished

func startLoadingHome():
	homeScene = ResourceLoader.load_threaded_request("res://scenes/home.tscn")
	loadHome()

func loadHome():
	await get_tree().create_timer(0.1).timeout
	match ResourceLoader.load_threaded_get_status("res://scenes/home.tscn"):
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			$introAnim.play("complete")
			await $introAnim.animation_finished
			homeScene = ResourceLoader.load_threaded_get("res://scenes/home.tscn")
			print(homeScene)
			get_tree().change_scene_to_packed(homeScene)
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			get_tree().change_scene_to_file("res://scenes/home.tscn")
			return
	loadHome()
