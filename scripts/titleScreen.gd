extends Node3D
# State variables
var homeScene = null
var animStarted:bool = true

# Steam app ID
var appID:String = "2841470"
# Steam connections
func _init():
	OS.set_environment("SteamAppID", appID)
	OS.set_environment("SteamGameID", appID)
# Called when scene loaded
func _ready() -> void:
	# Steam initialization
	Steam.steamInit()
	# Play boot anim
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$audioManager.play("title")
	
	$hud/fadeInAnim.play("fadeIn")
# Scan for player input, to start game
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and !animStarted: # Start intro anim
		animStarted = true
		$introAnim.play("intro")
		$menu.disabled = true
		# Prevent light flicker
		if GI.graphics == "HIGH":
			$WorldEnvironment.get_environment().set_sdfgi_enabled(true)
		# Fade out ambient audio
		var fadeTween := get_tree().create_tween()
		fadeTween.tween_property($audioManager/title, "volume_db", -80, 6.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		await $introAnim.animation_finished
# Load home scene in seperate thread
func startLoadingHome():
	homeScene = ResourceLoader.load_threaded_request("res://scenes/home.tscn")
	loadHome()
# Transition scene to home after it has finished loading
func loadHome():
	await get_tree().create_timer(0.1).timeout
	match ResourceLoader.load_threaded_get_status("res://scenes/home.tscn"): # Checks whether home has finished loading
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED: # Change to home scene
			$introAnim.play("complete")
			$completeBell.play()
			var fadeTween := get_tree().create_tween()
			fadeTween.tween_property($crtTurnOn, "volume_db", -80, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
			await $introAnim.animation_finished
			homeScene = ResourceLoader.load_threaded_get("res://scenes/home.tscn")
			print(homeScene)
			get_tree().change_scene_to_packed(homeScene)
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED: # Force home load if threaded load fails
			get_tree().change_scene_to_file("res://scenes/home.tscn")
			return
	loadHome() # Continue waiting for home to load
# Allow intro anim to be played
func allowIntro(): animStarted = false;
