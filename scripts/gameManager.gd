extends Node3D

@onready var player:Node = $player
@onready var playerCam:Node = $player/head/cam

@onready var pcCam:Node = $desk/monitorScreen/cam
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_pressed("back"):
		if pcCam.current:
			player.disabled = false
			player.get_node("HUD").visible = true
			playerCam.current = true
			pcCam.current = false

func _on_player_interacted(interactionName:String):
	match interactionName:
		"monitor":
			player.disabled = true
			player.get_node("HUD").visible = false
			playerCam.current = false
			pcCam.current = true
