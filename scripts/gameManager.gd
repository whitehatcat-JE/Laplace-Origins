extends Node3D

var inPasscodeScreen:bool = false
var redTransitionPlayed:bool = false

@onready var player:Node = $player
@onready var playerCam:Node = $player/head/cam

@onready var pcCam:Node = $bedroom/desk/monitorScreen/cam

@onready var audioManager:Node = $audioManager
@onready var routerSFX:Node = $walls/Router/routerSFX
@onready var screenSFX:Node = $screenInteractSFX
@onready var unplugSFX:Node = $bedroom/desk/Pc/unplugSFX
@onready var insertSFX:Node = $basement/crt/insertSFX

func _input(event):
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
			screenSFX.play()
			if GI.progress == 8:
				player.unlockedInteractions.erase("monitor")
				player.unlockedInteractions.append("exitHome")
				$pianoRoom/triggerField2.set_deferred("monitoring", true)
				$bedroom/easSFX.stop()
				$hallway/sirenSFX.stop()
				audioManager.play("none")
				$bedroom/pcWindow/pcOS/safeMessage.visible = true
				$powercutAnim.play("cutPower")
			else:
				player.disabled = true
				player.get_node("HUD").visible = false
				playerCam.current = false
				pcCam.current = true
		"router":
			routerSFX.play()
			player.unlockedInteractions.erase("router")
			if GI.progress == 6:
				GI.progress = 7
				$basement/crtAnim.play("redAllLights")
				$bedroom/roomTransformations.play("red")
				$pianoRoom/triggerField.set_deferred("monitoring", true)
				$pianoRoom/DoorFrame/doorAnims.play("openDoor")
				$walls/Router/routerLogo.visible = true
				$walls/Router/routerOffLogo.visible = false
				$pianoRoom/piano.visible = false
				audioManager.play("piano")
			else:
				GI.progress = 2
				$walls/Router/routerLogo.visible = false
				$walls/Router/routerOffLogo.visible = true
		"usb":
			unplugSFX.play()
			audioManager.play("hallway")
			$bedroom/desk/Pc/usbStick.visible = false
			player.unlockedInteractions.erase("usb")
			$walls/DoorFrame/doorAnims.play("openDoor")
			GI.progress = 4
		"passcode":
			screenSFX.play()
			player.disabled = true
			player.get_node("HUD").visible = false
			inPasscodeScreen = true
		"crt":
			insertSFX.play()
			$basement/crtAnim.play("displayMessage")
			audioManager.play("ambienceA")
			player.unlockedInteractions.erase("crt")
			player.unlockedInteractions.append("router")
			$basement/crt/usbStick.visible = true
			GI.progress = 6
		"piano":
			player.unlockedInteractions.erase("piano")
			$bedroom/easSFX.play()
			$hallway/sirenSFX.play()
			$bedroom/pcWindow/pcOS/emergencyAlert.visible = true
			$pianoRoom/eyes3.visible = true
			$pianoRoom/triggerField.set_deferred("monitoring", true)
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
			$bedroom/glitchSFX.play()
			if pcCam.current:
				redTransitionPlayed = true
				$bedroom/roomTransformations.play("red")
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
	if GI.progress == 8:
		$pianoRoom/eyes3.visible = false
		$audioManager/heartbeat.pitch_scale = 1.5
		return
	else:
		audioManager.play("heartbeat")
	$pianoRoom/eyes.visible = false
	$pianoRoom/SpotLight.visible = true
	$pianoRoom/piano.visible = true

func _on_fade_anim_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/outside.tscn")

func _on_trigger_field_2_body_entered(body):
	$pianoRoom/triggerField2.set_deferred("monitoring", false)
	$pianoRoom/eye2Anim.play("drawBack")
