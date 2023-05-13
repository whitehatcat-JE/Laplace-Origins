extends Node2D

signal exitOS
signal approvalEmailViewed

var mouseSensitivity:float = 0.5
var time:int = 0

var currentInteraction:String = ""
var menuDisplaying:bool = false
var emailDisplaying:bool = false
var filesDisplaying:bool = false
var cmdDisplaying:bool = false

var wifiEnabled:bool = true

var consoleCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()-=_+"
var consoleOutputList = [
	"3fourths Infinity [Version 7.321.43.5656.4]",
	"(c) Infinity Corporation. All rights reserved.",
	"",
	"C:/Users/Pierre> cmd -run laplace.exe",
	"> moving trainingSet to memory... 128GB loaded.",
	"> compiling node tree... complete.",
	"> establishing neural pathways... complete.",
	"> superuser access granted to Laplace.",
	"> now launching neural network... complete."
]

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
				emit_signal("exitOS")
			"emailOpen":
				if emailDisplaying:
					$homeScreen/emailWindow/emailAnims.play("emailDisappear")
				else:
					$homeScreen/emailWindow/emailAnims.play("emailAppear")
					emit_signal("approvalEmailViewed")
				emailDisplaying = !emailDisplaying
			"emailQuit":
				$homeScreen/emailWindow/emailAnims.play("emailDisappear")
				emailDisplaying = false
			"filesOpen":
				if filesDisplaying:
					$homeScreen/filesWindow/filesAnims.play("filesDisappear")
				else:
					$homeScreen/filesWindow/filesAnims.play("filesAppear")
				filesDisplaying = !filesDisplaying
			"filesQuit":
				$homeScreen/filesWindow/filesAnims.play("filesDisappear")
				filesDisplaying = false
			"laplaceExe":
				if GI.progress < 2:
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Please disable internet connection before running application."
				elif cmdDisplaying:
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Application already running."
				else:
					$homeScreen/consoleWindow/consoleAnims.play("consoleAppear")
					cmdDisplaying = true
			"cmdQuit":
				$homeScreen/errorWindow/backgroundShadow.color = "ff0800"
				$homeScreen/errorWindow/errorAnims.play("errorAppear")
				$homeScreen/errorWindow/errorMessage.text = "wN1bpgaHTlaLsGDkJTUHEyiF42dzL7M2wZI9q9sq8BshDi5GX1kTYWT40g8nhIBHkQRW8ELPFUYJePjUP6jztD1c70OFFDc9fpnP"
			"errorQuit":
				$homeScreen/errorWindow/errorAnims.play("errorDisappear")
			"errorOK":
				$homeScreen/errorWindow/errorAnims.play("errorDisappear")

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
			"filesOpen":
				$homeScreen/menuBar/files/fileBack.modulate = "ffffff00"
			"filesQuit":
				$homeScreen/filesWindow/quit/quitBack.modulate = "ffffff00"
			"laplaceExe":
				$homeScreen/filesWindow/laplaceBack.modulate = "ffffff00"
			"cmdQuit":
				$homeScreen/consoleWindow/quit/quitBack.modulate = "ffffff00"
			"emailOpen":
				$homeScreen/menuBar/email/emailBack.modulate = "ffffff00"
			"emailQuit":
				$homeScreen/emailWindow/quit/quitBack.modulate = "ffffff00"
			"errorOK":
				$homeScreen/errorWindow/continueBack.modulate = "393939d5"
			"errorQuit":
				$homeScreen/errorWindow/quit/quitBack.modulate = "ffffff00"
		match interaction:
			"login":
				$loginScreen/loginButton.modulate = "969696d5"
			"menu":
				$homeScreen/menuButton/menuButtonBackground.modulate = "969696d5"
			"logout":
				$homeScreen/menuBar/logout/logoutBack.modulate = "969696d5"
			"filesOpen":
				$homeScreen/menuBar/files/fileBack.modulate = "969696d5"
			"filesQuit":
				$homeScreen/filesWindow/quit/quitBack.modulate = "969696d5"
			"laplaceExe":
				$homeScreen/filesWindow/laplaceBack.modulate = "969696d5"
			"cmdQuit":
				$homeScreen/consoleWindow/quit/quitBack.modulate = "969696d5"
			"emailOpen":
				$homeScreen/menuBar/email/emailBack.modulate = "969696d5"
			"emailQuit":
				$homeScreen/emailWindow/quit/quitBack.modulate = "969696d5"
			"errorOK":
				$homeScreen/errorWindow/continueBack.modulate = "969696d5"
			"errorQuit":
				$homeScreen/errorWindow/quit/quitBack.modulate = "969696d5"
		currentInteraction = interaction
	
	if GI.progress == 2 and wifiEnabled:
		wifiEnabled = false
		$homeScreen/wifiIcon.texture = load("res://assets/2d/pcOS/wifiOffIcon.png")

func _on_clock_timer_timeout():
	time += 1
	var hour:int = (time / 60) % 24
	var sec:int = time % 60
	var newText:String = ("0" if hour < 10 else "") + str(hour) + ":"
	if sec < 10: newText += "0";
	newText += str(sec)
	
	$homeScreen/clock.text = newText

func _on_console_anims_animation_finished(anim_name):
	if anim_name == "consoleAppear":
		$homeScreen/consoleWindow/newLineTimer.start()

func _on_new_line_timer_timeout():
	consoleOutputList.append("C:/Users/Laplace>")
	for letter in range(randi_range(40, 50)):
		consoleOutputList[-1] += consoleCharacters[randi()% len(consoleCharacters)]
	if len(consoleOutputList) > 14: consoleOutputList.pop_front();
	$homeScreen/consoleWindow/consoleOutput.text = ""
	for output in consoleOutputList:
		$homeScreen/consoleWindow/consoleOutput.text += output + "\n"
