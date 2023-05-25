extends Node3D

enum MENU {
	start,
	settings,
	keybinds,
	quit
}

var menuOpen:bool = true

var curMenu:MENU = MENU.start

var unColor:Color = Color(1, 0, 0.05923652648926)
var unOutline:Color = Color(0.37109375, 0, 0.02198230475187)

var sColor:Color = Color(1, 0.56874907016754, 0)
var sOutline:Color = Color(0.28515625, 0.10666152834892, 0)

func _ready():
	get_tree().paused = true

func _input(event):
	if Input.is_action_just_pressed("menu"):
		if menuOpen: $mainAnims.play("zoom");
		else: $mainAnims.play_backwards("zoom");
		menuOpen = !menuOpen
	if !menuOpen: return;
	if Input.is_action_just_pressed("moveForward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.quit);
			MENU.settings: updateMainMenu(MENU.start);
			MENU.keybinds: updateMainMenu(MENU.settings);
			MENU.quit:updateMainMenu(MENU.keybinds);
	elif Input.is_action_just_pressed("moveBackward"):
		match curMenu:
			MENU.start: updateMainMenu(MENU.settings);
			MENU.settings: updateMainMenu(MENU.keybinds);
			MENU.keybinds: updateMainMenu(MENU.quit);
			MENU.quit: updateMainMenu(MENU.start);
	elif Input.is_action_just_pressed("interact"):
		match curMenu:
			MENU.start:
				$mainAnims.play("zoom")
				menuOpen = false
			MENU.quit:
				get_tree().quit()

func colorLabel(label:Label3D, iColor:Color, oColor:Color):
	label.modulate = iColor
	label.outline_modulate = oColor

func updateMainMenu(newMenu:MENU):
	match curMenu:
		MENU.start: colorLabel($startLabel, unColor, unOutline);
		MENU.settings: colorLabel($settingsLabel, unColor, unOutline);
		MENU.keybinds: colorLabel($keybindsLabel, unColor, unOutline);
		MENU.quit: colorLabel($quitLabel, unColor, unOutline);
	match newMenu:
		MENU.start: colorLabel($startLabel, sColor, sOutline);
		MENU.settings: colorLabel($settingsLabel, sColor, sOutline);
		MENU.keybinds: colorLabel($keybindsLabel, sColor, sOutline);
		MENU.quit: colorLabel($quitLabel, sColor, sOutline);
	curMenu = newMenu

func switchPauseState():
	get_tree().paused = menuOpen
	$startLabel.text = "Continue"
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
