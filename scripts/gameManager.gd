extends Node3D

var questNum = 0

@onready var player:Node = $player
@onready var playerCam:Node = $player/head/cam

@onready var pcCam:Node = $bedroom/desk/monitorScreen/cam
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("back"):
		if pcCam.current:
			player.disabled = false
			player.get_node("HUD").visible = true
			playerCam.current = true
			pcCam.current = false
	elif pcCam.current:
		$bedroom/pcWindow/pcOS.eventTriggered(event)

func _on_player_interacted(interactionName:String):
	match interactionName:
		"monitor":
			player.disabled = true
			player.get_node("HUD").visible = false
			playerCam.current = false
			pcCam.current = true
		"router":
			player.unlockedInteractions.erase("router")
			$walls/Router/routerLogo.visible = false
			$walls/Router/routerOffLogo.visible = true
			GI.progress = 2
		"usb":
			$bedroom/desk/Pc/usbStick.visible = false
			player.unlockedInteractions.erase("usb")
			$walls/DoorFrame/doorAnims.play("openDoor")
			GI.progress = 4

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
