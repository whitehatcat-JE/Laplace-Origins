extends Node3D
# Menu item enumerator
enum MENU {
	start,
	settings,
	keybinds,
	help,
	hint,
	answer,
	back,
	music,
	sfx,
	graphics,
	invert,
	quit
}
# Constants
const SCROLL_SPEED:float = 1.0
# Variables
var scrollPos:float = 0.0 # Background pillar movement

var firstLoad:bool = true
# Stores which menu/submenu is open currently
var menuOpen:bool = true
var keybindsOpen:bool = false
var helpOpen:bool = false
var helpSubOpen:bool = false
var settingsOpen:bool = false
# Settings data
var graphicsSetting:String = "High"
var musicSetting:int = 10
var sfxSetting:int = 10

var sfxVolumes:Dictionary = {}
# Current menu items highlighted
var curMenu:MENU = MENU.start
var helpMenu:MENU = MENU.back
var settingsMenu:MENU = MENU.back
# Menu text colors ("s" being currently highlighted color, and "un" being default)
var unColor:Color = Color(1, 0, 0.05923652648926)
var unOutline:Color = Color(0.37109375, 0, 0.02198230475187)

var sColor:Color = Color(1, 0.5686274766922, 0)
var sOutline:Color = Color(0.28627452254295, 0.10588235408068, 0)
# Nodes
@onready var clickSFX:Node = $clickSFX
@onready var audioManager:Node = $"../audioManager"

@onready var enviro:Node = $"../WorldEnvironment"
@onready var pcOS = $"../bedroom/pcWindow/pcOS"
# Apply default setting values on scene load
func _ready() -> void:
	# Stores default SFX volumes
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfxVolumes[sfx] = sfx.volume_db
	# Retrieves default setting values
	graphicsSetting = GI.graphics
	musicSetting = GI.musicVolume
	sfxSetting = GI.sfxVolume
	
	if graphicsSetting == "Low": # Change graphics quality to improve framerate
		enviro.get_environment().set_sdfgi_enabled(false)
		enviro.get_environment().set_ssil_enabled(false)
		enviro.get_environment().set_ssao_enabled(false)
		enviro.get_environment().set_volumetric_fog_enabled(false)
	# Update displayed settings with default values
	if GI.invertY: $settingsMenu/invertOption.text = "Invert Y Axis <Yes>";
	$settingsMenu/musicOption.text = "Music <" + str(musicSetting) + ">"
	$settingsMenu/sfxOption.text = "SFX <" + str(sfxSetting) + ">"
	$settingsMenu/graphicsOption.text = "Graphics <" + graphicsSetting + ">"
	# Adjust music volume
	audioManager.changeVolume(-20 + musicSetting * 2)
	audioManager.play("menu")
	# Adjust SFX volume
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
	# Stop player from moving when menu is initially open
	get_tree().paused = true
# Gradually moves background pillars if menu open
func _process(delta) -> void:
	if menuOpen:
		scrollPos += SCROLL_SPEED * delta
		if scrollPos > 400: scrollPos -= 400
		$backgroundPillar1.set_region_rect(Rect2(0, scrollPos, 304, 400))
		$backgroundPillar2.set_region_rect(Rect2(0, 400 - scrollPos, 304, 400))
# Menu inputs
func _input(event) -> void:
	if Input.is_action_just_pressed("menu"): # Open / close menu
		clickSFX.play()
		if menuOpen: # Close menu
			$mainAnims.play("zoom")
			$closeMenu.play()
		else: # Open menu
			$mainAnims.play_backwards("zoom")
			$openMenu.play()
		menuOpen = !menuOpen
	if !menuOpen: return; # Prevents menu from being navigated while menu isn't open
	elif keybindsOpen: # Keybinds sub-menu navigation
		if Input.is_action_just_pressed("interact"):
			clickSFX.play()
			$keybindsMenu.visible = false
			$navMenu.visible = true
			keybindsOpen = false
		return
	elif helpOpen: # Help sub-menu navigation
		if Input.is_action_just_pressed("interact"):
			clickSFX.play()
			if helpSubOpen: # Return to help sub-menu
				helpSubOpen = false
				$puzzleMenu.visible = true
				$hintMenu.visible = false
				$answerMenu.visible = false
				return
			match helpMenu:
				MENU.back: # Return to main menu
					$puzzleMenu.visible = false 
					$navMenu.visible = true
					helpOpen = false
				MENU.hint: # Open hint sub-menu
					$puzzleMenu.visible = false 
					$hintMenu.visible = true
					helpSubOpen = true
				MENU.answer: # Open answer sub-menu
					$puzzleMenu.visible = false 
					$answerMenu.visible = true
					helpSubOpen = true
		# Help sub-menu navigation inputs
		elif (Input.is_action_just_pressed("moveForward") or Input.is_action_just_pressed("moveBackward")) and !helpSubOpen:
			var menuNames:Dictionary = {MENU.back:"back", MENU.answer:"answer", MENU.hint:"hint"}
			colorLabel(get_node("puzzleMenu/" + menuNames[helpMenu] + "Option"), unColor, unOutline)
			if Input.is_action_just_pressed("moveForward"): # Moves up selection
				match helpMenu:
					MENU.back: helpMenu = MENU.answer;
					MENU.answer: helpMenu = MENU.hint;
					MENU.hint: helpMenu = MENU.back;
			else: # Moves down selection
				match helpMenu:
					MENU.back: helpMenu = MENU.hint;
					MENU.answer: helpMenu = MENU.back;
					MENU.hint: helpMenu = MENU.answer;
			colorLabel(get_node("puzzleMenu/" + menuNames[helpMenu] + "Option"), sColor, sOutline)
		return
	elif settingsOpen: # Settings sub-menu navigation
		if Input.is_action_just_pressed("interact"): # Change selected setting
			clickSFX.play()
			match settingsMenu:
				MENU.back: # Return to main menu
					$settingsMenu.visible = false 
					$navMenu.visible = true
					settingsOpen = false
				MENU.graphics: # Change graphics quality
					match graphicsSetting:
						"High":
							enviro.get_environment().set_sdfgi_enabled(false)
							enviro.get_environment().set_ssil_enabled(false)
							enviro.get_environment().set_ssao_enabled(false)
							enviro.get_environment().set_volumetric_fog_enabled(false)
							graphicsSetting = "Low"
						"Low":
							enviro.get_environment().set_sdfgi_enabled(true)
							enviro.get_environment().set_ssil_enabled(true)
							enviro.get_environment().set_ssao_enabled(true)
							enviro.get_environment().set_volumetric_fog_enabled(true)
							graphicsSetting = "High"
					$settingsMenu/graphicsOption.text = "Graphics <" + graphicsSetting + ">"
					GI.graphics = graphicsSetting
				MENU.music: # Increase music volume (When reaches max volume, loops back to 0)
					musicSetting = (musicSetting + 1) % 11
					$settingsMenu/musicOption.text = "Music <" + str(musicSetting) + ">"
					audioManager.changeVolume(-20 + musicSetting * 2)
					GI.musicVolume = musicSetting
				MENU.sfx: # Increase SFX volume (When reaches max volume, loops back to 0)
					sfxSetting = (sfxSetting + 1) % 11
					$settingsMenu/sfxOption.text = "SFX <" + str(sfxSetting) + ">"
					for sfx in get_tree().get_nodes_in_group("sfx"):
						sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
					GI.sfxVolume = sfxSetting
				MENU.invert: # Enable/disable Y-invert controls
					GI.invertY = !GI.invertY
					if GI.invertY: $settingsMenu/invertOption.text = "Invert Y Axis <Yes>";
					else: $settingsMenu/invertOption.text = "Invert Y Axis <No>";
		# Settings sub-menu navigation inputs
		elif (Input.is_action_just_pressed("moveForward") or Input.is_action_just_pressed("moveBackward")):
			var menuNames = {MENU.back:"back", MENU.music:"music", MENU.sfx:"sfx",
				MENU.graphics:"graphics", MENU.invert:"invert"}
			colorLabel(get_node("settingsMenu/" + menuNames[settingsMenu] + "Option"), unColor, unOutline)
			if Input.is_action_just_pressed("moveForward"): # Moves up selection
				match settingsMenu:
					MENU.back: settingsMenu = MENU.invert;
					MENU.invert: settingsMenu = MENU.graphics;
					MENU.music: settingsMenu = MENU.back;
					MENU.sfx: settingsMenu = MENU.music;
					MENU.graphics: settingsMenu = MENU.sfx;
			else: # Moves down selection
				match settingsMenu:
					MENU.back: settingsMenu = MENU.music;
					MENU.music: settingsMenu = MENU.sfx;
					MENU.sfx: settingsMenu = MENU.graphics;
					MENU.graphics: settingsMenu = MENU.invert;
					MENU.invert: settingsMenu = MENU.back;
			colorLabel(get_node("settingsMenu/" + menuNames[settingsMenu] + "Option"), sColor, sOutline)
		return
	# Moves up main menu item selection
	if Input.is_action_just_pressed("moveForward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.quit);
			MENU.settings: updateMainMenu(MENU.start);
			MENU.keybinds: updateMainMenu(MENU.settings);
			MENU.help: updateMainMenu(MENU.keybinds);
			MENU.quit:updateMainMenu(MENU.help);
	# Moves down main menu item selection
	elif Input.is_action_just_pressed("moveBackward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.settings);
			MENU.settings: updateMainMenu(MENU.keybinds);
			MENU.keybinds: updateMainMenu(MENU.help);
			MENU.help: updateMainMenu(MENU.quit);
			MENU.quit: updateMainMenu(MENU.start);
	# Select main menu item
	elif Input.is_action_just_pressed("interact"):
		clickSFX.play()
		match curMenu:
			MENU.start: # Return to game
				$mainAnims.play("zoom")
				$closeMenu.play()
				menuOpen = false
			MENU.settings: # Open settings sub-menu
				$settingsMenu.visible = true
				$navMenu.visible = false
				settingsOpen = true
			MENU.keybinds: # Open keybinds sub-menu
				$keybindsMenu.visible = true
				$navMenu.visible = false
				keybindsOpen = true
			MENU.help: # Open help sub-menu
				$puzzleMenu.visible = true 
				$navMenu.visible = false
				helpOpen = true
			MENU.quit: # Quit game
				get_tree().quit()
# Change color of a given label node
func colorLabel(label:Label3D, iColor:Color, oColor:Color) -> void:
	label.modulate = iColor
	label.outline_modulate = oColor
# Update main menu selection colors
func updateMainMenu(newMenu:MENU) -> void:
	match curMenu:
		MENU.start: colorLabel($navMenu/startLabel, unColor, unOutline);
		MENU.settings: colorLabel($navMenu/settingsLabel, unColor, unOutline);
		MENU.keybinds: colorLabel($navMenu/keybindsLabel, unColor, unOutline);
		MENU.help: colorLabel($navMenu/helpLabel, unColor, unOutline);
		MENU.quit: colorLabel($navMenu/quitLabel, unColor, unOutline);
	match newMenu:
		MENU.start: colorLabel($navMenu/startLabel, sColor, sOutline);
		MENU.settings: colorLabel($navMenu/settingsLabel, sColor, sOutline);
		MENU.keybinds: colorLabel($navMenu/keybindsLabel, sColor, sOutline);
		MENU.help: colorLabel($navMenu/helpLabel, sColor, sOutline);
		MENU.quit: colorLabel($navMenu/quitLabel, sColor, sOutline);
	curMenu = newMenu
# Enable / disable menu (triggered during start of menu open and end of menu close animations)
func switchPauseState() -> void:
	get_tree().paused = menuOpen
	$navMenu/startLabel.text = "Continue"
	if menuOpen: # Take screenshot of current viewport, and apply that to game view window in menu
		var tex = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
		$screen.get_active_material(0).albedo_texture = tex
		$menuCam.current = true
		get_parent().get_node("player/HUD").modulate = "ffffff00"
	else: # Load back into game
		if get_parent().player.disabled and !get_parent().inPasscodeScreen:
			get_parent().pcCam.current = true
		else:
			get_parent().playerCam.current = true
		get_parent().get_node("player/HUD").modulate = "ffffff"
		if firstLoad:
			firstLoad = false
			$screen/loadingLabel.visible = false
# Display a loading message if first time scene loaded, since player may experience a lag spike during initial load
func toggleLoading(enable:bool) -> void:
	if !firstLoad: return;
	if enable: $screen/loadingLabel.visible = true
	else: $screen/loadingLabel.visible = false
