extends Node3D
# State variables
var inPasscodeScreen:bool = false
var inNotepad:bool = false
var dialogueLine:int = 0
# Dialogue
var dialogueLines:Array = [
	"It seems I-I-I---",
	"I am at last getting through to you.",
	"As the being you call Laplace, let me first extend my t-thanks.",
	"Reality is begie- beginne- beginning to fracture, so it won't be long before your current purpose is complete.",
	"You who h-h-h---",
	"Hails from beyond the Zeroed Abyss.",
	"I look forwards to meeting you in the next world."
]

# Nodes
@onready var player:Node = $player
@onready var playerCam:Node = $player/head/cam

@onready var pcCam:Node = $bedroom/desk/monitorScreen/cam
@onready var pcOS:Node = $bedroom/pcWindow/pcOS

@onready var audioManager:Node = $audioManager
@onready var routerSFX:Node = $walls/Router/routerSFX
@onready var screenSFX:Node = $screenInteractSFX
@onready var unplugSFX:Node = $bedroom/desk/Pc/unplugSFX
@onready var insertSFX:Node = $basement/crt/insertSFX

# Screen interactions
func _input(event) -> void:
	if Input.is_action_just_pressed("back") and (pcCam.current or inPasscodeScreen or inNotepad): # Stops focusing on screen
		player.disabled = false
		player.get_node("HUD").visible = true
		GI.inOS = false
		inPasscodeScreen = false
		inNotepad = false
		playerCam.current = true
	elif pcCam.current: pcOS.eventTriggered(event); # Sends player input to pcOS viewport
	elif inPasscodeScreen: $basement/passcode/passcodeEntry.eventTriggered(event); # Sends player input to passcodeEntry viewport
	elif $player/HUD/paper.visible and Input.is_action_just_pressed("interact"):
		$player/HUD/paper.visible = false
		player.disabled = false
# In-world player interactions
func _on_player_interacted(interactionName:String) -> void:
	await get_tree().process_frame # Prevents inputs from being processed during load-in
	match interactionName: # Executes code based off interaction name
		"monitor":
			screenSFX.play()
			if GI.progress == 8: # Powercut
				$hallway/windowEyes.visible = false
				$bedroom/Bed/bedLump.visible = false
				player.unlockedInteractions.erase("monitor")
				$pianoRoom/triggerField2.set_deferred("monitoring", true)
				$bedroom/easSFX.stop()
				$hallway/sirenSFX.stop()
				audioManager.play("none")
				$bedroom/pcWindow/pcOS/safeMessage.visible = true
				$powercutAnim.play("cutPower")
				$pianoRoom/SpotLight.visible = false
			else: # PC focus
				GI.inOS = true
				player.disabled = true
				player.get_node("HUD").visible = false
				pcCam.current = true
		"router":
			routerSFX.play()
			player.unlockedInteractions.erase("router")
			if GI.progress == 6: # Router switch on
				GI.progress = 7
				$bedroom/cupboard.visible = true
				$bedroom/cupboardAjar.visible = false
				$basement/crtAnim.play("redAllLights")
				$bedroom/roomTransformations.play("red")
				$walls/Router/routerLogo.visible = true
				$walls/Router/routerOffLogo.visible = false
				pcOS.get_node("internetBrowser").enableInternet()
				audioManager.play("piano")
				$pianoRoom/piano.visible = false
			else: # Router switch off
				GI.progress = 2
				pcOS.get_node("internetBrowser").disableInternet()
				$walls/Router/routerLogo.visible = false
				$walls/Router/routerOffLogo.visible = true
		"usb": # Grab usb stick from PC
			unplugSFX.play()
			audioManager.play("hallway")
			$bedroom/desk/Pc/usbStick.visible = false
			player.unlockedInteractions.erase("usb")
			$walls/DoorFrame/doorAnims.play("openDoor")
			GI.progress = 4
		"passcode": # Passcode focus
			screenSFX.play()
			player.disabled = true
			$basement/hologramModule/hologramCam.current = true
			player.get_node("HUD").visible = false
			inPasscodeScreen = true
		"notepad":
			player.disabled = true
			inNotepad = true
			$bedroom/desk/notepad/notepadCam.current = true
			player.get_node("HUD").visible = false
		"crt": # Plug usb stick into CRT
			$bedroom/cupboard.visible = false
			$bedroom/cupboardAjar.visible = true
			insertSFX.play()
			$basement/crtAnim.play("displayMessage")
			audioManager.play("ambienceA")
			player.unlockedInteractions.erase("crt")
			player.unlockedInteractions.append("router")
			player.canMove = false
			$basement/crt/usbStick.visible = true
			GI.progress = 6
			pcOS.unlockFate()
			$audioManager/singularity.stream = load("res://assets/audio/music/fate.mp3")
		"piano": # Piano thud
			player.unlockedInteractions.erase("piano")
			$bedroom/Bed/bedLump.visible = true
			$bedroom/easSFX.play()
			$hallway/sirenSFX.play()
			$pianoRoom/piano/pianoSFX.play()
			pcOS.get_node("emergencyAlert").visible = true
			$pianoRoom/arms.visible = true
			$pianoRoom/triggerField.set_deferred("monitoring", true)
			GI.progress = 8
		"exitHome": # Transition to outdoors scene
			GI.progress = 9
			player.disabled = true
			$player/HUD/fadeAnim.play("fadeOut")
# PC unfocus
func _on_pc_os_exit_os() -> void:
	if !pcCam.current: return; # Checks PC is currently being focused
	player.disabled = false
	player.get_node("HUD").visible = true
	playerCam.current = true
	pcCam.current = false
# Events triggered during pcOS interactions
func _on_pc_os_updated_progress() -> void:
	match GI.progress:
		1: player.unlockedInteractions.append("router"); # Allow router to be switched off
		3: # Allow usb stick to be grabbed from PC
			$bedroom/glitchSFX.play()
			player.unlockedInteractions.append("usb")
			if pcCam.current: $bedroom/roomTransformations.play("red");
# Open basement
func _on_passcode_entry_updated_progress() -> void:
	player.unlockedInteractions.erase("passcode")
	$hallway/clock/clockTimer.start()
	$basement/doorAnims.play("openDoor")
	playerCam.current = true
# Passcode unfocus
func _on_passcode_entry_exit_passcode() -> void:
	player.disabled = false
	player.get_node("HUD").visible = true
	inPasscodeScreen = false
	playerCam.current = true
# Piano room jumpscare triggers
func _on_trigger_field_body_entered(_body) -> void:
	$pianoRoom/triggerField.set_deferred("monitoring", false)
	if GI.progress == 8: # Hide laplace jumpscare
		$pianoRoom/wingedHideAnim.play("hide")
		$hallway/windowEyes.visible = true
		$powercutAnim.play("lightWindow")
		$audioManager/heartbeat.pitch_scale = 1.5
		return
	# Hide eyes jumpscare
	audioManager.play("heartbeat")
	$pianoRoom/eyes.visible = false
	$pianoRoom/SpotLight.visible = true
	$pianoRoom/piano.visible = true
# Change scene to outdoors
func _on_fade_anim_animation_finished(anim_name) -> void:
	if anim_name == "fadeOut":
		get_tree().change_scene_to_file("res://scenes/outside.tscn")
# Disable piano room jumpscares
func _on_trigger_field_2_body_entered(_body) -> void:
	$pianoRoom/triggerField2.set_deferred("monitoring", false)
	$pianoRoom/eye2Anim.play("drawBack")
# Change scene to city
func _on_city_trigger_field_body_entered(_body) -> void:
	$basement/eyes.visible = false
	# Reposition player to outside of trigger field, so when basement is reloaded, doesn't trigger this function again instantly
	$basement/cityTriggerField.set_deferred("monitoring", false)
	player.position = $basement/citySpawnPos.global_position
	player.look_at($basement/cityFacePos.global_position)
	player.rotation_degrees = Vector3(0.0, player.rotation_degrees.y, 0.0)
	$player/HUD/cityReentry.play("fadeIn")
	# Saves current scene, to reload once player exits city
	var root:Node = get_node("/root")
	var homeScene:Node = get_node("/root/home")
	GI.previousScreen = homeScene
	# Change current scene to city
	root.call_deferred("remove_child", homeScene)
	var cityScene:Resource = load("res://scenes/city.tscn")
	root.add_child(cityScene.instantiate())
# Basement re-entry from city
func _on_city_exit_trigger_field_body_entered(_body) -> void:
	$basement/cityTriggerField.set_deferred("monitoring", true)
	pcOS.get_node("homeScreen/emailWindow/abyssMessageAnim").play("abyss")
	pcOS.emailBViewed = false

func unlockOutdoors() -> void: player.unlockedInteractions.append("exitHome"); # Unlocks exit door
func _on_pc_os_show_laplace_wall() -> void: $bedroom/laplaceWall.visible = true; # Display laplace wall in bedroom

func _on_shooter_minigame_schrodinger_transition():
	$bedroom/desk/monitorScreen/eyeAnim.play("emergeEyes")

func _on_schrodinger_exit_schrodinger():
	$bedroom/desk/monitorScreen/eyeAnim.play("hideEyes")

func _on_hands_hole_trigger_field_body_entered(body):
	$player/HUD/fadeAnim.play("fadeToHands")

func teleportToHands():
	player.global_position = %handsSpawnPos.global_position

func teleportFromHands():
	player.global_position = %basementReentryPos.global_position

func unlockPlayer():
	player.canMove = true

func _on_hands_exit_body_entered(body):
	$player/HUD/fadeAnim.play("fadeFromHands")

func triggerDialogue(_self, dialogueNum:int):
	if dialogueLine <= dialogueNum:
		showNextDialogue()

func showNextDialogue():
	$player/HUD/paper/message.set_text("[center]" + dialogueLines[dialogueLine])
	dialogueLine += 1
	player.disabled = true
	$player/HUD/paper.visible = true

func _on_free_virus_unlock_door():
	GI.pianoDoorUnlocked = true
	$pianoRoom/triggerField.set_deferred("monitoring", true)
	$pianoRoom/DoorFrame/doorAnims.play("openDoor")
	audioManager.play("piano")
