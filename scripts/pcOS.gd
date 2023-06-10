extends Node2D

signal exitOS
signal updatedProgress
signal showLaplaceWall

var mouseSensitivity:float = 0.5
var time:int = 0

var currentInteraction:String = ""
var menuDisplaying:bool = false
var filesDisplaying:bool = false
var cmdDisplaying:bool = false

var emailDisplaying:bool = false
var emailCDisplaying:bool = false

var wifiEnabled:bool = true

var alertCharNum:int = 0

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

@onready var clickSFX:Node = $clickSFX
@onready var deniedSFX:Node = $deniedSFX

func _ready() -> void:
	$homeScreen.position.x = 100000

func eventTriggered(event) -> void:
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
				clickSFX.play()
			"menu":
				clickSFX.play()
				if menuDisplaying:
					$homeScreen/menuBar/menuAnims.play("disappear")
				else:
					$homeScreen/menuBar/menuAnims.play("appear")
				menuDisplaying = !menuDisplaying
			"logout":
				clickSFX.play()
				$homeScreen/menuBar/menuAnims.play("disappear")
				menuDisplaying = false
				$loginScreen.position.x = 0
				$homeScreen.position.x = 10000
				emit_signal("exitOS")
			"emailOpen":
				clickSFX.play()
				if emailDisplaying:
					$homeScreen/emailWindow/emailAnims.play("emailDisappear")
				else:
					$homeScreen/emailWindow/emailAnims.play("emailAppear")
					if GI.progress == 0:
						GI.progress = 1
						emit_signal("updatedProgress")
				emailDisplaying = !emailDisplaying
			"emailQuit":
				clickSFX.play()
				$homeScreen/emailWindow/emailAnims.play("emailDisappear")
				emailDisplaying = false
			"emailA":
				clickSFX.play()
				$homeScreen/emailWindow/emailA/description.visible = true
				$homeScreen/emailWindow/emailB/description.visible = false
				$homeScreen/emailWindow/emailC/description.visible = false
			"emailB":
				clickSFX.play()
				$homeScreen/emailWindow/emailA/description.visible = false
				$homeScreen/emailWindow/emailB/description.visible = true
				$homeScreen/emailWindow/emailC/description.visible = false
			"emailC":
				clickSFX.play()
				$homeScreen/emailWindow/emailA/description.visible = false
				$homeScreen/emailWindow/emailB/description.visible = false
				$homeScreen/emailWindow/emailC/description.visible = true
			"filesOpen":
				clickSFX.play()
				if filesDisplaying:
					$homeScreen/filesWindow/filesAnims.play("filesDisappear")
				else:
					$homeScreen/filesWindow/filesAnims.play("filesAppear")
				filesDisplaying = !filesDisplaying
			"filesQuit":
				clickSFX.play()
				$homeScreen/filesWindow/filesAnims.play("filesDisappear")
				filesDisplaying = false
			"laplaceExe":
				if GI.progress < 2:
					deniedSFX.play()
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Please disable internet connection before running application."
				elif cmdDisplaying:
					deniedSFX.play()
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Application already running."
				else:
					clickSFX.play()
					$homeScreen/consoleWindow/consoleAnims.play("consoleAppear")
					cmdDisplaying = true
			"cmdQuit":
				deniedSFX.play()
				$homeScreen/errorWindow/backgroundShadow.color = "ff0800"
				$homeScreen/errorWindow/errorAnims.play("errorAppear")
				$homeScreen/errorWindow/errorMessage.text = "wN1bpgaHTlaLsGDkJTUHEyiF42dzL7M2wZI9q9sq8BshDi5GX1kTYWT40g8nhIBHkQRW8ELPFUYJePjUP6jztD1c70OFFDc9fpnP"
			"errorQuit":
				clickSFX.play()
				$homeScreen/errorWindow/errorAnims.play("errorDisappear")
			"errorOK":
				clickSFX.play()
				$homeScreen/errorWindow/errorAnims.play("errorDisappear")
			"shooterOpen":
				clickSFX.play()
				$shooterMinigame.visible = true
				$shooterMinigame.start()
				$mouse/pointerRay.set_collision_mask_value(2, false)
				$mouse/pointerRay.set_collision_mask_value(3, true)
			"shooterQuit":
				clickSFX.play()
				$shooterMinigame.killGame()
				$shooterMinigame.visible = false
				$shooterMinigame.stop()
				$mouse/pointerRay.set_collision_mask_value(2, true)
				$mouse/pointerRay.set_collision_mask_value(3, false)
			"shooterBegin":
				$clickRetroSFX.play()
				$shooterMinigame.begin()

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
			"emailA":
				$homeScreen/emailWindow/emailA/emailABack.modulate = "ffffff00"
			"emailB":
				$homeScreen/emailWindow/emailB/emailBBack.modulate = "ffffff00"
			"emailC":
				$homeScreen/emailWindow/emailC/emailCBack.modulate = "ffffff00"
			"errorOK":
				$homeScreen/errorWindow/continueBack.modulate = "393939d5"
			"errorQuit":
				$homeScreen/errorWindow/quit/quitBack.modulate = "ffffff00"
			"shooterOpen":
				$homeScreen/menuBar/shooter/shooterBack.modulate = "ffffff00"
			"shooterQuit":
				$shooterMinigame/HUD/quit/quitBack.modulate = "ffffff00"
			"shooterBegin":
				$shooterMinigame/HUD/beginButton.texture = $shooterMinigame.beginTexture
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
			"emailA":
				$homeScreen/emailWindow/emailA/emailABack.modulate = "969696d5"
			"emailB":
				$homeScreen/emailWindow/emailB/emailBBack.modulate = "969696d5"
			"emailC":
				$homeScreen/emailWindow/emailC/emailCBack.modulate = "969696d5"
			"errorOK":
				$homeScreen/errorWindow/continueBack.modulate = "969696d5"
			"errorQuit":
				$homeScreen/errorWindow/quit/quitBack.modulate = "969696d5"
			"shooterOpen":
				$homeScreen/menuBar/shooter/shooterBack.modulate = "969696d5"
			"shooterQuit":
				$shooterMinigame/HUD/quit/quitBack.modulate = "969696d5"
			"shooterBegin":
				$shooterMinigame/HUD/beginButton.texture = $shooterMinigame.hoverTexture
		currentInteraction = interaction
	
	if GI.progress == 2 and wifiEnabled:
		wifiEnabled = false
		$homeScreen/wifiIcon.texture = load("res://assets/2d/pcOS/wifiOffIcon.png")
	if GI.progress == 6 and !emailCDisplaying:
		$background.texture = load("res://assets/2d/pcOS/dropBackgroundC.png")
		emailCDisplaying = true
		$homeScreen/emailWindow/emailC.visible = true
		$homeScreen/emailWindow/emailA/description.visible = false
		$homeScreen/emailWindow/emailA/description.text = """Looks like the stakeholders have finally given us the go-ahead to do another test run!

Just run   it immEdiate|y and let it do its thing."""
		$homeScreen/emailWindow/emailB/description.visible = false
		$homeScreen/emailWindow/emailC/description.visible = true
		$homeScreen/emailWindow/emailC/interact/hitbox.disabled = false

func _on_clock_timer_timeout() -> void:
	time += 1
	var hour:int = (time / 60) % 24
	var sec:int = time % 60
	var newText:String = ("0" if hour < 10 else "") + str(hour) + ":"
	if sec < 10: newText += "0";
	newText += str(sec)
	
	$homeScreen/clock.text = newText

func unlockUSB() -> void:
	$homeScreen/consoleWindow/newLineTimer.start()
	GI.progress = 3
	$homeScreen/emailWindow/emailB.visible = true
	$homeScreen/emailWindow/emailA/description.visible = false
	$homeScreen/emailWindow/emailB/description.visible = true
	$homeScreen/emailWindow/emailB/interact/hitbox.disabled = false
	$background.texture = load("res://assets/2d/pcOS/dropBackgroundB.png")
	emit_signal("updatedProgress")

func _on_new_line_timer_timeout() -> void:
	consoleOutputList.append("C:/Users/Laplace>")
	for letter in range(randi_range(40, 50)):
		consoleOutputList[-1] += consoleCharacters[randi()% len(consoleCharacters)]
	if len(consoleOutputList) > 14: consoleOutputList.pop_front();
	$homeScreen/consoleWindow/consoleOutput.text = ""
	for output in consoleOutputList:
		$homeScreen/consoleWindow/consoleOutput.text += output + "\n"

func _on_alert_scroll_timer_timeout() -> void:
	var currentText:String = $emergencyAlert/alertText.text
	alertCharNum += 1
	currentText = ("UNKNOWN "[7 - alertCharNum % 8] + currentText).substr(0, 300)
	$emergencyAlert/alertText.text = currentText


func _on_shooter_minigame_laplace_spawned():
	$background.visible = false
	$backgroundLaplace.visible = true
	emit_signal("showLaplaceWall")
