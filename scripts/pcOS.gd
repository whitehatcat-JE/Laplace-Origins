extends Node2D
# Signals
signal exitOS
signal updatedProgress
signal showLaplaceWall
# State variables
var mouseSensitivity:float = 0.5
var time:int = 0

var currentInteraction:String = ""
var menuDisplaying:bool = false
var filesDisplaying:bool = false
var cmdDisplaying:bool = false

var displayingArticle1:bool = false
var displayingArticle2:bool = false
var displayingArticle3:bool = false

var emailDisplaying:bool = false
var emailCDisplaying:bool = false

var emailAViewed:bool = false
var emailBViewed:bool = false
var emailCViewed:bool = false

var wifiEnabled:bool = true

var alertCharNum:int = 0
# Console variables
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
# Screen boundaries
@onready var minX:float = $boundaryNW.position.x
@onready var maxX:float = $boundarySE.position.x
@onready var minY:float = $boundaryNW.position.y
@onready var maxY:float = $boundarySE.position.y
# Mouse collision raycast
@onready var mousePtr:Node = $mouse/pointerRay
# Audio nodes
@onready var clickSFX:Node = $clickSFX
@onready var deniedSFX:Node = $deniedSFX
# Hides homescreen while login screen visible
func _ready() -> void: $homeScreen.position.x = 100000;
# Player inputs
func eventTriggered(event) -> void:
	if event is InputEventMouseMotion: # Move mouse
		var newPos:Vector2 = $mouse.position + (event.relative * mouseSensitivity)
		newPos.x = clamp(newPos.x, minX, maxX)
		newPos.y = clamp(newPos.y, minY, maxY)
		$mouse.position = newPos
	elif Input.is_action_just_pressed("interact") and currentInteraction != "": # Click button
		var playDefaultClickSFX:bool = true
		match currentInteraction:
			"login": # Replace login screen with homescreen
				$loginScreen.position.x = 10000
				$homeScreen.position.x = 0
			"menu": # Open / close navigation menu
				updateEmailCount()
				$homeScreen/menuBar/menuAnims.play(
					"disappear" if menuDisplaying else "appear")
				menuDisplaying = !menuDisplaying
			"logout": # Replace homescreen with login screen
				$homeScreen/menuBar/menuAnims.play("disappear")
				menuDisplaying = false
				$loginScreen.position.x = 0
				$homeScreen.position.x = 10000
				emit_signal("exitOS")
			"emailOpen": # Open / close email window
				$homeScreen/emailWindow/emailAnims.play(
					"emailDisappear" if emailDisplaying else "emailAppear")
				if GI.progress == 0: # Unlocks ability to switch off router
					GI.progress = 1
					emit_signal("updatedProgress")
				emailDisplaying = !emailDisplaying
				if $homeScreen/emailWindow/emailA/description.visible:
					emailAViewed = true
				elif $homeScreen/emailWindow/emailB/description.visible:
					emailBViewed = true
				elif $homeScreen/emailWindow/emailC/description.visible:
					emailCViewed = true
				updateEmailCount()
			"emailQuit": # Close email window
				$homeScreen/emailWindow/emailAnims.play("emailDisappear")
				emailDisplaying = false
			"emailA": # Show email A
				$homeScreen/emailWindow/emailA/description.visible = true
				$homeScreen/emailWindow/emailB/description.visible = false
				$homeScreen/emailWindow/emailC/description.visible = false
				emailAViewed = true
				updateEmailCount()
			"emailB": # Show email B
				$homeScreen/emailWindow/emailA/description.visible = false
				$homeScreen/emailWindow/emailB/description.visible = true
				$homeScreen/emailWindow/emailC/description.visible = false
				emailBViewed = true
				updateEmailCount()
			"emailC": # Show email C
				$homeScreen/emailWindow/emailA/description.visible = false
				$homeScreen/emailWindow/emailB/description.visible = false
				$homeScreen/emailWindow/emailC/description.visible = true
				emailCViewed = true
				updateEmailCount()
			"filesOpen": # Open / close file window
				$homeScreen/filesWindow/filesAnims.play(
					"filesDisappear" if filesDisplaying else "filesAppear")
				filesDisplaying = !filesDisplaying
			"filesQuit": # Close file window
				$homeScreen/filesWindow/filesAnims.play("filesDisappear")
				filesDisplaying = false
			"laplaceExe": # Open console window
				if GI.progress < 2: # Deny open if player hasn't switched off router
					deniedSFX.play()
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Please disable internet connection before running application."
				elif cmdDisplaying: # Deny open if console already open
					playDefaultClickSFX = false
					deniedSFX.play()
					$homeScreen/errorWindow/backgroundShadow.color = "0000006a"
					$homeScreen/errorWindow/errorAnims.play("errorAppear")
					$homeScreen/errorWindow/errorMessage.text = "Application already running."
				else: # Open console
					$homeScreen/consoleWindow/consoleAnims.play("consoleAppear")
					cmdDisplaying = true
			"cmdQuit": # Display error message when player attempts to close console
				playDefaultClickSFX = false
				deniedSFX.play()
				$homeScreen/errorWindow/backgroundShadow.color = "ff0800"
				$homeScreen/errorWindow/errorAnims.play("errorAppear")
				$homeScreen/errorWindow/errorMessage.text = "wN1bpgaHTlaLsGDkJTUHEyiF42dzL7M2wZI9q9sq8BshDi5GX1kTYWT40g8nhIBHkQRW8ELPFUYJePjUP6jztD1c70OFFDc9fpnP"
			"errorQuit": $homeScreen/errorWindow/errorAnims.play("errorDisappear"); # Error message exit button
			"errorOK": $homeScreen/errorWindow/errorAnims.play("errorDisappear"); # Error message ok button
			"singularityExe": # Open shooter minigame
				$shooterMinigame.visible = true
				$shooterMinigame.start()
				$mouse/pointerRay.set_collision_mask_value(2, false)
				$mouse/pointerRay.set_collision_mask_value(3, true)
			"shooterQuit": # Close shooter minigame
				$shooterMinigame.killGame()
				$shooterMinigame.visible = false
				$shooterMinigame.stop()
				$mouse/pointerRay.set_collision_mask_value(2, true)
				$mouse/pointerRay.set_collision_mask_value(3, false)
			"shooterBegin": # Start round of shooter minigame
				playDefaultClickSFX = false
				$clickRetroSFX.play()
				$shooterMinigame.begin()
			"internetOpen":
				$internetBrowser.visible = true
				$mouse/pointerRay.set_collision_mask_value(2, false)
				$mouse/pointerRay.set_collision_mask_value(4, true)
			"internetQuit":
				$internetBrowser.visible = false
				$mouse/pointerRay.set_collision_mask_value(2, true)
				$mouse/pointerRay.set_collision_mask_value(4, false)
			"search":
				if GI.progress > 2:
					if $internetBrowser/homepage/resultsWeep.position.y > 1000:
						$internetBrowser/homepage/homepageAnims.play("showResultsWeep")
					else:
						$internetBrowser/homepage/homepageAnims.play("hideResultsWeep")
				else:
					if $internetBrowser/homepage/results.position.y > 1000:
						$internetBrowser/homepage/homepageAnims.play("showResults")
					else:
						$internetBrowser/homepage/homepageAnims.play("hideResults")
			"newsResultsBack":
				if displayingArticle1:
					displayingArticle1 = false
					$internetBrowser/newsResults/newsAnims.play("hideArticle1")
				elif displayingArticle2:
					displayingArticle2 = false
					$internetBrowser/newsResults/newsAnims.play("hideArticle2")
				else:
					$internetBrowser/newsResults/newsAnims.play("hideNews")
			"newsSearch":
				$internetBrowser/weatherResults/weatherAnims.play("hideWeather")
				$internetBrowser/weatherResults/weatherAnims.advance(2.0)
				$internetBrowser/gameResults/gameAnims.play("hideGames")
				$internetBrowser/gameResults/gameAnims.advance(2.0)
				$internetBrowser/newsResults/newsAnims.play("showNews")
			"newsArticle1":
				displayingArticle1 = true
				$internetBrowser/newsResults/newsAnims.play("showArticle1")
			"newsArticle2":
				displayingArticle2 = true
				$internetBrowser/newsResults/newsAnims.play("showArticle2")
			"weatherResultsBack":
				if displayingArticle1:
					displayingArticle1 = false
					$internetBrowser/weatherResults/weatherAnims.play("hideArticle1")
				else:
					$internetBrowser/weatherResults/weatherAnims.play("hideWeather")
			"weatherSearch":
				$internetBrowser/newsResults/newsAnims.play("hideNews")
				$internetBrowser/newsResults/newsAnims.advance(2.0)
				$internetBrowser/gameResults/gameAnims.play("hideGames")
				$internetBrowser/gameResults/gameAnims.advance(2.0)
				$internetBrowser/weatherResults/weatherAnims.play("showWeather")
			"weatherArticle1":
				displayingArticle1 = true
				$internetBrowser/weatherResults/weatherAnims.play("showArticle1")
			"gameResultsBack":
				if displayingArticle1:
					displayingArticle1 = false
					$internetBrowser/gameResults/gameAnims.play("hideArticle1")
				elif displayingArticle2:
					displayingArticle2 = false
					$internetBrowser/gameResults/gameAnims.play("hideArticle2")
				elif displayingArticle3:
					displayingArticle3 = false
					$internetBrowser/gameResults/gameAnims.play("hideArticle3")
				else:
					$internetBrowser/gameResults/gameAnims.play("hideGames")
			"gameSearch":
				$internetBrowser/weatherResults/weatherAnims.play("hideWeather")
				$internetBrowser/weatherResults/weatherAnims.advance(2.0)
				$internetBrowser/newsResults/newsAnims.play("hideNews")
				$internetBrowser/newsResults/newsAnims.advance(2.0)
				$internetBrowser/gameResults/gameAnims.play("showGames")
				$internetBrowser/gameResults/article1/description/descriptionAnim.play("flickerDate")
			"gameArticle1":
				displayingArticle1 = true
				$internetBrowser/gameResults/gameAnims.play("showArticle1")
			"gameArticle2":
				displayingArticle2 = true
				$internetBrowser/gameResults/gameAnims.play("showArticle2")
			"gameArticle3":
				displayingArticle3 = true
				$internetBrowser/gameResults/gameAnims.play("showArticle3")
			"downloadSingularity":
				$internetBrowser/download/downloadAnim.play("download")
			"slimyBirdStart":
				$internetBrowser/gameResults/article2Open/slimyBirdGame.start()
			"imageResultsBack":
				$internetBrowser/imageResults/imageAnims.play("hideImages")
			"imageSearch":
				$internetBrowser/weatherResults/weatherAnims.play("hideWeather")
				$internetBrowser/weatherResults/weatherAnims.advance(2.0)
				$internetBrowser/newsResults/newsAnims.play("hideNews")
				$internetBrowser/newsResults/newsAnims.advance(2.0)
				$internetBrowser/gameResults/gameAnims.play("hideGames")
				$internetBrowser/gameResults/gameAnims.advance(2.0)
				$internetBrowser/homepage/homepageAnims.play("hideResultsWeep")
				$internetBrowser/homepage/homepageAnims.advance(2.0)
				$internetBrowser/imageResults/imageAnims.play("showImages")
		if playDefaultClickSFX: clickSFX.play();
# Checks if mouse currently hovered over button
func _process(delta) -> void:
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
		match currentInteraction:
			"login": $loginScreen/loginButton.modulate = "393939d5";
			"menu": $homeScreen/menuButton/menuButtonBackground.modulate = "ffffff00";
			"logout": $homeScreen/menuBar/logout/logoutBack.modulate = "ffffff00";
			"filesOpen": $homeScreen/menuBar/files/fileBack.modulate = "ffffff00";
			"filesQuit": $homeScreen/filesWindow/quit/quitBack.modulate = "ffffff00";
			"laplaceExe": $homeScreen/filesWindow/laplaceBack.modulate = "ffffff00";
			"singularityExe": $homeScreen/filesWindow/singularityBack.modulate = "ffffff00";
			"cmdQuit": $homeScreen/consoleWindow/quit/quitBack.modulate = "ffffff00";
			"emailOpen": $homeScreen/menuBar/email/emailBack.modulate = "ffffff00";
			"emailQuit": $homeScreen/emailWindow/quit/quitBack.modulate = "ffffff00";
			"emailA": $homeScreen/emailWindow/emailA/emailABack.modulate = "ffffff00";
			"emailB": $homeScreen/emailWindow/emailB/emailBBack.modulate = "ffffff00";
			"emailC": $homeScreen/emailWindow/emailC/emailCBack.modulate = "ffffff00";
			"errorOK": $homeScreen/errorWindow/continueBack.modulate = "393939d5";
			"errorQuit": $homeScreen/errorWindow/quit/quitBack.modulate = "ffffff00";
			"shooterQuit": $shooterMinigame/HUD/quit/quitBack.modulate = "ffffff00";
			"shooterBegin": $shooterMinigame/HUD/beginButton.texture = $shooterMinigame.beginTexture;
			"internetOpen": $homeScreen/menuBar/internet/internetBack.modulate = "ffffff00";
			"internetQuit": $internetBrowser/quit/quitBack.modulate = "ffffff00";
			"newsArticle1": $internetBrowser/newsResults/article1/hoverAnims.play("unhover");
			"newsArticle2": $internetBrowser/newsResults/article2/hoverAnims.play("unhover");
			"weatherArticle1": $internetBrowser/weatherResults/article1/hoverAnims.play("unhover");
			"gameArticle1": $internetBrowser/gameResults/article1/hoverAnims.play("unhover");
			"gameArticle2": $internetBrowser/gameResults/article2/hoverAnims.play("unhover");
			"gameArticle3": $internetBrowser/gameResults/article3/hoverAnims.play("unhover");
			"slimyBirdStart": $internetBrowser/gameResults/article2Open/slimyBirdGame/startButton/startButtonHovered.visible = false;
		# Changes color of button currently hovered
		match interaction:
			"login": $loginScreen/loginButton.modulate = "969696d5";
			"menu": $homeScreen/menuButton/menuButtonBackground.modulate = "969696d5";
			"logout": $homeScreen/menuBar/logout/logoutBack.modulate = "969696d5";
			"filesOpen": $homeScreen/menuBar/files/fileBack.modulate = "969696d5";
			"filesQuit": $homeScreen/filesWindow/quit/quitBack.modulate = "969696d5";
			"laplaceExe": $homeScreen/filesWindow/laplaceBack.modulate = "969696d5";
			"singularityExe": $homeScreen/filesWindow/singularityBack.modulate = "969696d5";
			"cmdQuit": $homeScreen/consoleWindow/quit/quitBack.modulate = "969696d5";
			"emailOpen": $homeScreen/menuBar/email/emailBack.modulate = "969696d5";
			"emailQuit": $homeScreen/emailWindow/quit/quitBack.modulate = "969696d5";
			"emailA": $homeScreen/emailWindow/emailA/emailABack.modulate = "969696d5";
			"emailB": $homeScreen/emailWindow/emailB/emailBBack.modulate = "969696d5";
			"emailC": $homeScreen/emailWindow/emailC/emailCBack.modulate = "969696d5";
			"errorOK": $homeScreen/errorWindow/continueBack.modulate = "969696d5";
			"errorQuit": $homeScreen/errorWindow/quit/quitBack.modulate = "969696d5";
			"shooterQuit": $shooterMinigame/HUD/quit/quitBack.modulate = "969696d5";
			"shooterBegin": $shooterMinigame/HUD/beginButton.texture = $shooterMinigame.hoverTexture;
			"internetOpen": $homeScreen/menuBar/internet/internetBack.modulate = "969696d5";
			"internetQuit": $internetBrowser/quit/quitBack.modulate = "969696d5";
			"newsArticle1": $internetBrowser/newsResults/article1/hoverAnims.play("hover");
			"newsArticle2": $internetBrowser/newsResults/article2/hoverAnims.play("hover");
			"weatherArticle1": $internetBrowser/weatherResults/article1/hoverAnims.play("hover");
			"gameArticle1": $internetBrowser/gameResults/article1/hoverAnims.play("hover");
			"gameArticle2": $internetBrowser/gameResults/article2/hoverAnims.play("hover");
			"gameArticle3": $internetBrowser/gameResults/article3/hoverAnims.play("hover");
			"slimyBirdStart": $internetBrowser/gameResults/article2Open/slimyBirdGame/startButton/startButtonHovered.visible = true;
		currentInteraction = interaction  # Stores currently hovered button
	
	if GI.progress == 2 and wifiEnabled: # Updates wifi icon if internet off
		wifiEnabled = false
		$homeScreen/wifiIcon.texture = load("res://assets/2d/pcOS/wifiOffIcon.png")
	if GI.progress == 6 and !emailCDisplaying: # Update email A contents after CRT interacted with
		$background.texture = load("res://assets/2d/pcOS/dropBackgroundC.png")
		emailCDisplaying = true
		$homeScreen/emailWindow/emailC.visible = true
		$homeScreen/emailWindow/emailA/description.visible = false
		$homeScreen/emailWindow/emailA/description.text = """Looks like the stakeholders have finally given us the go-ahead to do another test run!

Just run   it immEdiate|y and let it do its thing."""
		$homeScreen/emailWindow/emailB/description.visible = false
		$homeScreen/emailWindow/emailC/description.visible = true
		$homeScreen/emailWindow/emailC/interact/hitbox.disabled = false
		updateEmailCount()
# Increment time displayed
func _on_clock_timer_timeout() -> void:
	time += 1 # Increment time
	# Format new time
	var hour:int = (time / 60) % 24
	var min:int = time % 60
	var newText:String = ("0" if hour < 10 else "") + str(hour) + ":"
	if min < 10: newText += "0";
	newText += str(min)
	# Display new time
	$homeScreen/clock.text = newText
# Update OS after console window runs
func unlockUSB() -> void:
	$homeScreen/consoleWindow/newLineTimer.start()
	GI.progress = 3
	$homeScreen/emailWindow/emailB.visible = true
	$homeScreen/emailWindow/emailA/description.visible = false
	$homeScreen/emailWindow/emailB/description.visible = true
	$homeScreen/emailWindow/emailB/interact/hitbox.disabled = false
	$background.texture = load("res://assets/2d/pcOS/dropBackgroundB.png")
	emit_signal("updatedProgress") # Allows player to interact with USB stick in PC
	updateEmailCount()
# Draw new line of random characters to console
func _on_new_line_timer_timeout() -> void:
	consoleOutputList.append("C:/Users/Laplace>")
	for letter in range(randi_range(40, 50)):
		consoleOutputList[-1] += consoleCharacters[randi()% len(consoleCharacters)]
	if len(consoleOutputList) > 14: consoleOutputList.pop_front();
	$homeScreen/consoleWindow/consoleOutput.text = ""
	for output in consoleOutputList:
		$homeScreen/consoleWindow/consoleOutput.text += output + "\n"
# Scroll text during alert message
func _on_alert_scroll_timer_timeout() -> void:
	var currentText:String = $emergencyAlert/alertText.text
	alertCharNum += 1
	currentText = ("UNKNOWN "[7 - alertCharNum % 8] + currentText).substr(0, 300)
	$emergencyAlert/alertText.text = currentText
# Unlock shooter minigame laplace easter egg
func _on_shooter_minigame_laplace_spawned():
	$background.visible = false
	$backgroundLaplace.visible = true
	emit_signal("showLaplaceWall")

func _on_internet_browser_downloaded_singularity():
	$homeScreen/filesWindow/singularityExe.position.x = 0

func updateEmailCount():
	var totalUnreadEmails = 0
	if !emailAViewed: totalUnreadEmails += 1
	if !emailBViewed and $homeScreen/emailWindow/emailB.visible and $homeScreen/emailWindow.position.x > 1000: totalUnreadEmails += 1
	if !emailCViewed and $homeScreen/emailWindow/emailC.visible and $homeScreen/emailWindow.position.x > 1000: totalUnreadEmails += 1
	if totalUnreadEmails > 0:
		$homeScreen/menuBar/email/notificationDot.visible = true
		$homeScreen/menuBar/email/notificationDot/notificationCount.text = str(totalUnreadEmails)
	else:
		$homeScreen/menuBar/email/notificationDot.visible = false

func _on_internet_browser_enable_wifi():
	$homeScreen/wifiIcon.texture = load("res://assets/2d/pcOS/wifiIcon.png")
	$homeScreen/menuBar/internet/glitchedInternet.play("glitch")

func unlockFate():
	$homeScreen/menuBar/menuAnims.play("glitchShooter")
	$homeScreen/filesWindow/singularityExe/singularityIcon.texture = load("res://assets/2d/shooterMinigame/playerCorrupt.png")
	$homeScreen/filesWindow/singularityExe/singularityName.text = "   fate.exe"
	$homeScreen/filesWindow/singularityExe/singularityName.modulate = Color.RED
