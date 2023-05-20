extends Node3D

var inPasscodeScreen:bool = false

@onready var player:Node = $player
@onready var playerCam:Node = $player/head/cam

@onready var pcCam:Node = $bedroom/desk/monitorScreen/cam

func _input(event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("back"):
		if pcCam.current:
			player.disabled = false
			player.get_node("HUD").visible = true
			playerCam.current = true
			pcCam.current = false
		elif inPasscodeScreen:
			player.disabled = false
			player.get_node("HUD").visible = true
			inPasscodeScreen = false
	elif pcCam.current:
		$bedroom/pcWindow/pcOS.eventTriggered(event)
	elif inPasscodeScreen:
		$basement/passcode/passcodeEntry.eventTriggered(event)

func _on_player_interacted(interactionName:String):
	await get_tree().process_frame
	match interactionName:
		"monitor":
			if GI.progress == 8:
				player.unlockedInteractions.erase("monitor")
				player.unlockedInteractions.append("exitHome")
				$bedroom/easSFX.stop()
				$hallway/sirenSFX.stop()
				$pianoRoom/pianoSongGlitched.play()
				$bedroom/pcWindow/pcOS/safeMessage.visible = true
				$powercutAnim.play("cutPower")
			else:
				player.disabled = true
				player.get_node("HUD").visible = false
				playerCam.current = false
				pcCam.current = true
		"router":
			player.unlockedInteractions.erase("router")
			if GI.progress == 6:
				GI.progress = 7
				$basement/crtAnim.play("redAllLights")
				$pianoRoom/triggerField.set_deferred("monitoring", true)
				$pianoRoom/DoorFrame/doorAnims.play("openDoor")
				$walls/Router/routerLogo.visible = true
				$walls/Router/routerOffLogo.visible = false
				$pianoRoom/piano.visible = false
				$pianoRoom/pianoSong.play()
			else:
				GI.progress = 2
				$walls/Router/routerLogo.visible = false
				$walls/Router/routerOffLogo.visible = true
		"usb":
			$bedroom/desk/Pc/usbStick.visible = false
			player.unlockedInteractions.erase("usb")
			$walls/DoorFrame/doorAnims.play("openDoor")
			GI.progress = 4
		"passcode":
			player.disabled = true
			player.get_node("HUD").visible = false
			inPasscodeScreen = true
		"crt":
			$basement/crtAnim.play("displayMessage")
			player.unlockedInteractions.erase("crt")
			player.unlockedInteractions.append("router")
			$basement/crt/usbStick.visible = true
			GI.progress = 6
		"piano":
			player.unlockedInteractions.erase("piano")
			$bedroom/easSFX.play()
			$hallway/sirenSFX.play()
			$bedroom/pcWindow/pcOS/emergencyAlert.visible = true
			GI.progress = 8
		"exitHome":
			GI.progress = 9
			player.disabled = true
			$player/HUD/fadeAnim.play("fadeOut")

func _on_pc_os_exit_os():
	if pcCam.current:
		player.disabled = false
		player.get_node("HUD").visible = true
		playerCam.current = true
		pcCam.current = false

func _on_pc_os_updated_progress():
	match GI.progress:
		1:
			player.unlockedInteractions.append("router")
		3:
			if pcCam.current: $bedroom/roomTransformations.play("red");
			player.unlockedInteractions.append("usb")

func _on_passcode_entry_updated_progress():
	player.unlockedInteractions.erase("passcode")
	$basement/doorAnims.play("openDoor")

func _on_passcode_entry_exit_passcode():
	player.disabled = false
	player.get_node("HUD").visible = true
	inPasscodeScreen = false

func _on_trigger_field_body_entered(body):
	$pianoRoom/triggerField.set_deferred("monitoring", false)
	$pianoRoom/eyes.visible = false
	$pianoRoom/SpotLight.visible = true
	$pianoRoom/piano.visible = true
	$pianoRoom/pianoSong.stop()

func _on_fade_anim_animation_finished(anim_name):
	print("Transferring...")
