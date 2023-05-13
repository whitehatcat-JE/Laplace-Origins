extends Node2D

var mouseSensitivity:float = 0.5
var time:int = 0

var currentInteraction:String = ""
var menuDisplaying:bool = false

@onready var minX:float = $boundaryNW.position.x
@onready var maxX:float = $boundarySE.position.x
@onready var minY:float = $boundaryNW.position.y
@onready var maxY:float = $boundarySE.position.y

@onready var mousePtr:Node = $mouse/pointerRay

func _ready():
	#return
	$homeScreen.position.x = 100000

func eventTriggered(event):
	if event is InputEventMouseMotion:
		var newPos:Vector2 = $mouse.position + (event.relative * mouseSensitivity)
		newPos.x = clamp(newPos.x, minX, maxX)
		newPos.y = clamp(newPos.y, minY, maxY)
		$mouse.position = newPos
	elif Input.is_action_just_pressed("interact") and currentInteraction != "":
		match currentInteraction:
			"login":
				$loginScreen.position.x = 10000
				$homeScreen.position.x = 0
			"menu":
				if menuDisplaying:
					$homeScreen/menuBar/menuAnims.play("disappear")
				else:
					$homeScreen/menuBar/menuAnims.play("appear")
				menuDisplaying = !menuDisplaying
			"logout":
				$homeScreen/menuBar/menuAnims.play("disappear")
				menuDisplaying = false
				$loginScreen.position.x = 0
				$homeScreen.position.x = 10000

func _process(delta):
	$mouse/mousePointer.visible = false
	$mouse/mouseInteract.visible = false
	var interaction:String = ""
	if mousePtr.is_colliding():
		interaction = mousePtr.get_collider().interactionName
		$mouse/mouseInteract.visible = true
	else:
		interaction = ""
		$mouse/mousePointer.visible = true
	
	if interaction != currentInteraction:
		match currentInteraction:
			"login":
				$loginScreen/loginButton.modulate = "393939d5"
			"menu":
				$homeScreen/menuButton/menuButtonBackground.modulate = "ffffff00"
			"logout":
				$homeScreen/menuBar/logout/logoutBack.modulate = "ffffff00"
			"fileOpen":
				$homeScreen/menuBar/files/fileBack.modulate = "ffffff00"
			"emailOpen":
				$homeScreen/menuBar/email/emailBack.modulate = "ffffff00"
		match interaction:
			"login":
				$loginScreen/loginButton.modulate = "969696d5"
			"menu":
				$homeScreen/menuButton/menuButtonBackground.modulate = "969696d5"
			"logout":
				$homeScreen/menuBar/logout/logoutBack.modulate = "969696d5"
			"fileOpen":
				$homeScreen/menuBar/files/fileBack.modulate = "969696d5"
			"emailOpen":
				$homeScreen/menuBar/email/emailBack.modulate = "969696d5"
		currentInteraction = interaction


func _on_clock_timer_timeout():
	time += 1
	var hour:int = (time / 60) % 24
	var sec:int = time % 60
	var newText:String = ("0" if hour < 10 else "") + str(hour) + ":"
	if sec < 10: newText += "0";
	newText += str(sec)
	
	$homeScreen/clock.text = newText
