extends Node3D

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
	quit
}

const SCROLL_SPEED:float = 1.0
var scrollPos:float = 0.0

var menuOpen:bool = true
var keybindsOpen:bool = false
var helpOpen:bool = false
var helpSubOpen:bool = false
var settingsOpen:bool = false

var graphicsSetting:String = "High"
var musicSetting:int = 10
var sfxSetting:int = 10

var sfxVolumes:Dictionary = {}

var curMenu:MENU = MENU.start
var helpMenu:MENU = MENU.back
var settingsMenu:MENU = MENU.back

var unColor:Color = Color(1, 0, 0.05923652648926)
var unOutline:Color = Color(0.37109375, 0, 0.02198230475187)

var sColor:Color = Color(1, 0.5686274766922, 0)
var sOutline:Color = Color(0.28627452254295, 0.10588235408068, 0)

@onready var clickSFX:Node = $clickSFX
@onready var enviro:Node = $"../WorldEnvironment"

@onready var pcOS = $"../bedroom/pcWindow/pcOS"

func _ready() -> void:
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfxVolumes[sfx] = sfx.volume_db
	
	graphicsSetting = GI.graphics
	musicSetting = GI.musicVolume
	sfxSetting = GI.sfxVolume
	
	if graphicsSetting == "Low":
		enviro.get_environment().set_sdfgi_enabled(false)
		enviro.get_environment().set_ssil_enabled(false)
		enviro.get_environment().set_ssao_enabled(false)
		enviro.get_environment().set_volumetric_fog_enabled(false)
		$settingsMenu/graphicsOption.text = "Graphics <" + graphicsSetting + ">"
	
	$settingsMenu/musicOption.text = "Music <" + str(musicSetting) + ">"
	$"../audioManager".changeVolume(-20 + musicSetting * 2)
	$"../audioManager".play("menu")
	
	$settingsMenu/sfxOption.text = "SFX <" + str(sfxSetting) + ">"
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
	
	get_tree().paused = true

func _process(delta) -> void:
	if menuOpen:
		scrollPos += SCROLL_SPEED * delta
		if scrollPos > 400: scrollPos -= 400
		$backgroundPillar1.set_region_rect(Rect2(0, scrollPos, 304, 400))
		$backgroundPillar2.set_region_rect(Rect2(0, 400 - scrollPos, 304, 400))

func _input(event) -> void:
	if Input.is_action_just_pressed("menu"):
		clickSFX.play()
		if menuOpen:
			$mainAnims.play("zoom")
			$closeMenu.play()
		else:
			$mainAnims.play_backwards("zoom")
			$openMenu.play()
		menuOpen = !menuOpen
	if !menuOpen: return;
	elif keybindsOpen:
		if Input.is_action_just_pressed("interact"):
			clickSFX.play()
			$keybindsMenu.visible = false
			$navMenu.visible = true
			keybindsOpen = false
		return
	elif helpOpen:
		if Input.is_action_just_pressed("interact"):
			clickSFX.play()
			if helpSubOpen:
				helpSubOpen = false
				$puzzleMenu.visible = true
				$hintMenu.visible = false
				$answerMenu.visible = false
				return
			match helpMenu:
				MENU.back:
					$puzzleMenu.visible = false 
					$navMenu.visible = true
					helpOpen = false
				MENU.hint:
					$puzzleMenu.visible = false 
					$hintMenu.visible = true
					helpSubOpen = true
				MENU.answer:
					$puzzleMenu.visible = false 
					$answerMenu.visible = true
					helpSubOpen = true
		elif (Input.is_action_just_pressed("moveForward") or Input.is_action_just_pressed("moveBackward")) and !helpSubOpen:
			var menuNames = {MENU.back:"back", MENU.answer:"answer", MENU.hint:"hint"}
			colorLabel(get_node("puzzleMenu/" + menuNames[helpMenu] + "Option"), unColor, unOutline)
			if Input.is_action_just_pressed("moveForward"):
				match helpMenu:
					MENU.back: helpMenu = MENU.answer;
					MENU.answer: helpMenu = MENU.hint;
					MENU.hint: helpMenu = MENU.back;
			else:
				match helpMenu:
					MENU.back: helpMenu = MENU.hint;
					MENU.answer: helpMenu = MENU.back;
					MENU.hint: helpMenu = MENU.answer;
			colorLabel(get_node("puzzleMenu/" + menuNames[helpMenu] + "Option"), sColor, sOutline)
		return
	elif settingsOpen:
		if Input.is_action_just_pressed("interact"):
			clickSFX.play()
			match settingsMenu:
				MENU.back:
					$settingsMenu.visible = false 
					$navMenu.visible = true
					settingsOpen = false
				MENU.graphics:
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
				MENU.music:
					musicSetting = (musicSetting + 1) % 11
					$settingsMenu/musicOption.text = "Music <" + str(musicSetting) + ">"
					$"../audioManager".changeVolume(-20 + musicSetting * 2)
					GI.musicVolume = musicSetting
				MENU.sfx:
					sfxSetting = (sfxSetting + 1) % 11
					$settingsMenu/sfxOption.text = "SFX <" + str(sfxSetting) + ">"
					for sfx in get_tree().get_nodes_in_group("sfx"):
						sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
					GI.sfxVolume = sfxSetting
		elif (Input.is_action_just_pressed("moveForward") or Input.is_action_just_pressed("moveBackward")):
			var menuNames = {MENU.back:"back", MENU.music:"music", MENU.sfx:"sfx", MENU.graphics:"graphics"}
			colorLabel(get_node("settingsMenu/" + menuNames[settingsMenu] + "Option"), unColor, unOutline)
			if Input.is_action_just_pressed("moveForward"):
				match settingsMenu:
					MENU.back: settingsMenu = MENU.graphics;
					MENU.music: settingsMenu = MENU.back;
					MENU.sfx: settingsMenu = MENU.music;
					MENU.graphics: settingsMenu = MENU.sfx;
			else:
				match settingsMenu:
					MENU.back: settingsMenu = MENU.music;
					MENU.music: settingsMenu = MENU.sfx;
					MENU.sfx: settingsMenu = MENU.graphics;
					MENU.graphics: settingsMenu = MENU.back;
			colorLabel(get_node("settingsMenu/" + menuNames[settingsMenu] + "Option"), sColor, sOutline)
		return
	if Input.is_action_just_pressed("moveForward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.quit);
			MENU.settings: updateMainMenu(MENU.start);
			MENU.keybinds: updateMainMenu(MENU.settings);
			MENU.help: updateMainMenu(MENU.keybinds);
			MENU.quit:updateMainMenu(MENU.help);
	elif Input.is_action_just_pressed("moveBackward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.settings);
			MENU.settings: updateMainMenu(MENU.keybinds);
			MENU.keybinds: updateMainMenu(MENU.help);
			MENU.help: updateMainMenu(MENU.quit);
			MENU.quit: updateMainMenu(MENU.start);
	elif Input.is_action_just_pressed("interact"):
		clickSFX.play()
		match curMenu:
			MENU.start:
				$mainAnims.play("zoom")
				$closeMenu.play()
				menuOpen = false
			MENU.settings:
				$settingsMenu.visible = true
				$navMenu.visible = false
				settingsOpen = true
			MENU.keybinds:
				$keybindsMenu.visible = true
				$navMenu.visible = false
				keybindsOpen = true
			MENU.help:
				$puzzleMenu.visible = true 
				$navMenu.visible = false
				helpOpen = true
			MENU.quit:
				get_tree().quit()

func colorLabel(label:Label3D, iColor:Color, oColor:Color) -> void:
	label.modulate = iColor
	label.outline_modulate = oColor

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

func switchPauseState() -> void:
	get_tree().paused = menuOpen
	$navMenu/startLabel.text = "Continue"
	if menuOpen:
		var tex = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
		$screen.get_active_material(0).albedo_texture = tex
		$menuCam.current = true
		get_parent().get_node("player/HUD").modulate = "ffffff00"
	else:
		if get_parent().player.disabled and !get_parent().inPasscodeScreen:
			get_parent().pcCam.current = true
		else:
			get_parent().playerCam.current = true
		get_parent().get_node("player/HUD").modulate = "ffffff"
