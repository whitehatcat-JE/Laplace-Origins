extends Node2D
# Signals
signal updatedProgress
signal exitPasscode
# State variables
var mouseSensitivity:float = 0.5

var justInteracted:bool = false

var currentInteraction:String = ""
var buttonHeld:String = ""
var passcode:String = "912346"
var userCode:String = ""
# Screen borders
@onready var minX:float = $boundaryNW.position.x
@onready var maxX:float = $boundarySE.position.x
@onready var minY:float = $boundaryNW.position.y
@onready var maxY:float = $boundarySE.position.y
# Mouse collision raycast (For interacting with buttons)
@onready var mousePtr:Node = $mouse/pointerRay
# Audio nodes
@onready var buttonSFX:Node = $buttonSFX
@onready var confirmationSFX:Node = $confirmationSFX
# Checks if user input matches passcode
func buttonPressed(num:String) -> void:
	userCode += num
	if len(userCode) > 15: userCode = num; # Resets passcode
	elif userCode == passcode: # Checks if passcode correct
		modulate = "32ff00"
		$backdrop.texture = load("res://assets/2d/passcode/backgroundNoiseGreen.png")
		GI.progress = 5
		confirmationSFX.play()
		emit_signal("updatedProgress")
		emit_signal("exitPasscode")
	$passcodeNumbers.text = str(userCode) # Records new user input as part of passcode
# Button events
func eventTriggered(event) -> void:
	if event is InputEventMouseMotion: # Moves virtual mouse
		var newPos:Vector2 = $mouse.position + (event.relative * mouseSensitivity)
		newPos.x = clamp(newPos.x, minX, maxX)
		newPos.y = clamp(newPos.y, minY, maxY)
		$mouse.position = newPos
	elif Input.is_action_just_pressed("interact") and currentInteraction != "" and !justInteracted: # Runs button event
		justInteracted = true
		buttonHeld = currentInteraction
		buttonSFX.play()
		if currentInteraction in "0123456789": # Number inputs
			buttonPressed(currentInteraction)
			get_node("b" + currentInteraction).modulate = "5cff53"
			return
		match currentInteraction: # Control button inputs
			"reload": # Resets user inputs 
				userCode = ""
				$passcodeNumbers.text = str(userCode)
				$reloadButton.modulate = "5cff53"
			"quit": # Unfocus self
				$cancelButton.modulate = "ffffff"
				emit_signal("exitPasscode")
	elif Input.is_action_just_released("interact") and buttonHeld != "": # Resets currently hovered button color
		var newColor:String = "59d3ff" if buttonHeld == currentInteraction else "ffffff"
		if buttonHeld == "reload": $reloadButton.modulate = newColor;
		elif buttonHeld in "0123456789": get_node("b" + buttonHeld).modulate = newColor;
		buttonHeld = ""
# Checks if mouse currently hovered over button
func _process(delta) -> void:
	justInteracted = false
	# Updates mouse icon if hovered over button
	$mouse/mousePointer.visible = false
	$mouse/mouseInteract.visible = false
	var interaction:String = ""
	if mousePtr.is_colliding():
		interaction = mousePtr.get_collider().interactionName
		$mouse/mouseInteract.visible = true
	else: $mouse/mousePointer.visible = true;
	# Changes color of button mouse hovering over
	if interaction != currentInteraction:
		# Resets color of button previously hovered
		if currentInteraction in "0123456789":
			get_node("b" + currentInteraction).modulate = "ffffff"
		elif currentInteraction == "reload": $reloadButton.modulate = "ffffff";
		elif currentInteraction == "quit": $cancelButton.modulate = "ffffff";
		# Changes color of button currently hovered
		if interaction in "0123456789":
			get_node("b" + interaction).modulate = "59d3ff"
		elif interaction == "reload": $reloadButton.modulate = "59d3ff";
		elif interaction == "quit": $cancelButton.modulate = "ff000c";
		currentInteraction = interaction # Stores currently hovered button
