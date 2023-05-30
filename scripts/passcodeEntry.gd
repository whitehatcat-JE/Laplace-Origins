extends Node2D

signal updatedProgress
signal exitPasscode

var mouseSensitivity:float = 0.5

var currentInteraction:String = ""

var buttonHeld:String = ""
var passcode:String = "624754"
var zeroedPasscode:String = "0624070504"
var userCode:String = ""

@onready var minX:float = $boundaryNW.position.x
@onready var maxX:float = $boundarySE.position.x
@onready var minY:float = $boundaryNW.position.y
@onready var maxY:float = $boundarySE.position.y

@onready var mousePtr:Node = $mouse/pointerRay

@onready var buttonSFX:Node = $buttonSFX
@onready var confirmationSFX:Node = $confirmationSFX

func buttonPressed(num:String) -> void:
	userCode += num
	if len(userCode) > 15: userCode = num;
	elif userCode == passcode or userCode == zeroedPasscode:
		modulate = "32ff00"
		$backdrop.texture = load("res://assets/2d/passcode/backgroundNoiseGreen.png")
		GI.progress = 5
		confirmationSFX.play()
		emit_signal("updatedProgress")
		emit_signal("exitPasscode")
	$passcodeNumbers.text = str(userCode)

func eventTriggered(event) -> void:
	if event is InputEventMouseMotion:
		var newPos:Vector2 = $mouse.position + (event.relative * mouseSensitivity)
		newPos.x = clamp(newPos.x, minX, maxX)
		newPos.y = clamp(newPos.y, minY, maxY)
		$mouse.position = newPos
	elif Input.is_action_just_pressed("interact") and currentInteraction != "":
		buttonHeld = currentInteraction
		buttonSFX.play()
		if currentInteraction in "0123456789": buttonPressed(currentInteraction);
		match currentInteraction:
			"0": $b0.modulate = "5cff53";
			"1": $b1.modulate = "5cff53";
			"2": $b2.modulate = "5cff53";
			"3": $b3.modulate = "5cff53";
			"4": $b4.modulate = "5cff53";
			"5": $b5.modulate = "5cff53";
			"6": $b6.modulate = "5cff53";
			"7": $b7.modulate = "5cff53";
			"8": $b8.modulate = "5cff53";
			"9": $b9.modulate = "5cff53";
			"reload":
				userCode = ""
				$passcodeNumbers.text = str(userCode)
				$reloadButton.modulate = "5cff53"
			"quit":
				$cancelButton.modulate = "ffffff"
				emit_signal("exitPasscode")
	elif Input.is_action_just_released("interact") and buttonHeld != "":
		match buttonHeld:
			"0": $b0.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"1": $b1.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"2": $b2.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"3": $b3.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"4": $b4.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"5": $b5.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"6": $b6.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"7": $b7.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"8": $b8.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"9": $b9.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
			"reload": $reloadButton.modulate = "59d3ff" if buttonHeld == currentInteraction else "ffffff";
		buttonHeld = ""

func _process(delta) -> void:
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
			"0": $b0.modulate = "ffffff";
			"1": $b1.modulate = "ffffff";
			"2": $b2.modulate = "ffffff";
			"3": $b3.modulate = "ffffff";
			"4": $b4.modulate = "ffffff";
			"5": $b5.modulate = "ffffff";
			"6": $b6.modulate = "ffffff";
			"7": $b7.modulate = "ffffff";
			"8": $b8.modulate = "ffffff";
			"9": $b9.modulate = "ffffff";
			"reload": $reloadButton.modulate = "ffffff";
			"quit": $cancelButton.modulate = "ffffff";
		match interaction:
			"0": $b0.modulate = "59d3ff";
			"1": $b1.modulate = "59d3ff";
			"2": $b2.modulate = "59d3ff";
			"3": $b3.modulate = "59d3ff";
			"4": $b4.modulate = "59d3ff";
			"5": $b5.modulate = "59d3ff";
			"6": $b6.modulate = "59d3ff";
			"7": $b7.modulate = "59d3ff";
			"8": $b8.modulate = "59d3ff";
			"9": $b9.modulate = "59d3ff";
			"reload": $reloadButton.modulate = "59d3ff";
			"quit": $cancelButton.modulate = "ff000c";
		currentInteraction = interaction
