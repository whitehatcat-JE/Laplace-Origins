extends Control
# Currently selected buttons
enum BUTTON {
	start,
	settings,
	controls,
	guide,
	quit,
	music,
	sfx,
	graphics,
	invert,
	vsync,
	guideBack,
	controlsBack,
	settingsBack
}
# Currently selected menu
enum MENU {
	main,
	settings,
	controls,
	guide
}
# Menu state variables
var menuOpen:bool = false
var disabled = false
var justInteracted:bool = false

# Tween animation for CRT
var crtTween:Tween = null
# Current button
var currentButton:BUTTON = BUTTON.start
# Current menu
var menuButtons:Dictionary = {
	MENU.main:[BUTTON.start, BUTTON.settings, BUTTON.controls, BUTTON.guide, BUTTON.quit],
	MENU.settings:[BUTTON.music, BUTTON.sfx, BUTTON.graphics, BUTTON.invert, BUTTON.vsync, BUTTON.settingsBack],
	MENU.controls:[BUTTON.controlsBack],
	MENU.guide:[BUTTON.guideBack]
	
}
# Menu setting values
var graphicsSetting:String = "High"
var musicSetting:int = 10
var sfxSetting:int = 10

var sfxVolumes:Dictionary = {}

var sdfgiDefault:bool = false
var ssilDefault:bool = false
var ssaoDefault:bool = false
var volFogDefault:bool = false
# Menu labels
@onready var textLabels:Array[Label] = [
	$controlsGrid/forwardKeybind,
	$controlsGrid/backwardKeybind, 
	$controlsGrid/leftKeybind, 
	$controlsGrid/rightKeybind, 
	$controlsGrid/wasdNote, 
	$controlsGrid/interactKeybind, 
	$controlsGrid/unfocusKeybind, 
	$controlsGrid/unfocusNote, 
	$controlsGrid/menuKeybind,
	$helpGrid/helpMessage
]
# Nodes setting can manipulate
@export var audioManager:Node = null
@export var enviro:Node = null

# Applies default menu settings
func _ready() -> void:
	# Hides menu
	closeMenu()
	crtTween.custom_step(1.0)
	# Stores default SFX volumes
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfxVolumes[sfx] = sfx.volume_db
	# Stores default graphics settings
	sdfgiDefault = enviro.get_environment().sdfgi_enabled
	ssilDefault = enviro.get_environment().ssil_enabled
	ssaoDefault = enviro.get_environment().ssao_enabled
	volFogDefault = enviro.get_environment().volumetric_fog_enabled
	# Updates graphics if on low graphics mode
	if GI.graphics == "LOW":
		enviro.get_environment().set_sdfgi_enabled(false)
		enviro.get_environment().set_ssil_enabled(false)
		enviro.get_environment().set_ssao_enabled(false)
		enviro.get_environment().set_volumetric_fog_enabled(false)
	# Updates displayed graphics setting
	graphicsSetting = GI.graphics
	$settingsGrid/graphicsButton.text = "Graphics <" + graphicsSetting + ">"
	# Updates displayed music 
	musicSetting = GI.musicVolume
	$settingsGrid/musicButton.text = "Music <" + str(musicSetting) + ">"
	# Updates displayed SFX
	sfxSetting = GI.sfxVolume 
	$settingsGrid/sfxButton.text = "SFX <" + str(sfxSetting) + ">"
	# Updates SFX volumes
	for sfx in get_tree().get_nodes_in_group("sfx"):
		sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
	# Updates displayed invert-y setting
	if GI.invertY: $settingsGrid/invertButton.text = "Invert Y <YES>";
	else: $settingsGrid/invertButton.text = "Invert Y <NO>";
	# Updates displayed vsync mode
	match GI.vsyncOrder[GI.vsyncNum]:
		GI.VSYNC_MODES.enabled: $settingsGrid/vsyncButton.text = "V-Sync <ON>";
		GI.VSYNC_MODES.locked60: $settingsGrid/vsyncButton.text = "V-Sync <60>";
		GI.VSYNC_MODES.disabled: $settingsGrid/vsyncButton.text = "V-Sync <OFF>";
# Menu input navigation
func _input(_event) -> void:
	if disabled: return; # Checks whether menu can be used
	# Hide / show menu
	if Input.is_action_just_pressed("menu") and !justInteracted:
		justInteracted = true
		if menuOpen: closeMenu();
		else: openMenu();
	
	if !menuOpen: return; # Checks whether menu is active
	# Menu upwards navigation
	if Input.is_action_just_pressed("moveForward") and !justInteracted:
		justInteracted = true
		if currentButton in menuButtons[MENU.main]:
			changeButton(menuButtons[MENU.main][wrapi(menuButtons[MENU.main].find(currentButton) - 1, 0, len(menuButtons[MENU.main]))])
		elif currentButton in menuButtons[MENU.settings]:
			changeButton(menuButtons[MENU.settings][wrapi(menuButtons[MENU.settings].find(currentButton) - 1, 0, len(menuButtons[MENU.settings]))])
	# Menu downwards navigation
	if Input.is_action_just_pressed("moveBackward") and !justInteracted:
		justInteracted = true
		if currentButton in menuButtons[MENU.main]:
			changeButton(menuButtons[MENU.main][wrapi(menuButtons[MENU.main].find(currentButton) + 1, 0, len(menuButtons[MENU.main]))])
		elif currentButton in menuButtons[MENU.settings]:
			changeButton(menuButtons[MENU.settings][wrapi(menuButtons[MENU.settings].find(currentButton) + 1, 0, len(menuButtons[MENU.settings]))])
	# Button events
	if Input.is_action_just_pressed("interact") and !justInteracted:
		justInteracted = true
		$clickSFX.play()
		match currentButton:
			# Menu navigation
			BUTTON.start:
				closeMenu()
			BUTTON.settings:
				$settingsGrid.visible = true
				$menuGrid.visible = false
				changeButton(BUTTON.settingsBack)
			BUTTON.controls:
				$controlsGrid.visible = true
				$menuGrid.visible = false
				changeButton(BUTTON.controlsBack)
			BUTTON.guide:
				$helpGrid.visible = true
				$menuGrid.visible = false
				changeButton(BUTTON.guideBack)
			BUTTON.quit:
				get_tree().quit()
			BUTTON.settingsBack:
				$settingsGrid.visible = false
				$menuGrid.visible = true
				changeButton(BUTTON.settings)
			BUTTON.controlsBack:
				$controlsGrid.visible = false
				$menuGrid.visible = true
				changeButton(BUTTON.controls)
			BUTTON.guideBack:
				$helpGrid.visible = false
				$menuGrid.visible = true
				changeButton(BUTTON.guide)
			# Settings
			BUTTON.graphics:
				match graphicsSetting:
					"HIGH":
						enviro.get_environment().set_sdfgi_enabled(false)
						enviro.get_environment().set_ssil_enabled(false)
						enviro.get_environment().set_ssao_enabled(false)
						enviro.get_environment().set_volumetric_fog_enabled(false)
						graphicsSetting = "LOW"
					"LOW":
						enviro.get_environment().set_sdfgi_enabled(sdfgiDefault)
						enviro.get_environment().set_ssil_enabled(ssilDefault)
						enviro.get_environment().set_ssao_enabled(ssaoDefault)
						enviro.get_environment().set_volumetric_fog_enabled(volFogDefault)
						graphicsSetting = "HIGH"
				$settingsGrid/graphicsButton.text = "Graphics <" + graphicsSetting + ">"
				GI.graphics = graphicsSetting
			BUTTON.music:
				musicSetting = (musicSetting + 1) % 11
				$settingsGrid/musicButton.text = "Music <" + str(musicSetting) + ">"
				audioManager.changeVolume(-20 + musicSetting * 2)
				GI.musicVolume = musicSetting
			BUTTON.sfx:
				sfxSetting = (sfxSetting + 1) % 11
				$settingsGrid/sfxButton.text = "SFX <" + str(sfxSetting) + ">"
				for sfx in get_tree().get_nodes_in_group("sfx"):
					sfx.volume_db = sfxVolumes[sfx] - (10 - sfxSetting) * 2 if sfxSetting > 0 else -80
				GI.sfxVolume = sfxSetting
			BUTTON.invert:
				GI.invertY = !GI.invertY
				if GI.invertY: $settingsGrid/invertButton.text = "Invert Y <YES>";
				else: $settingsGrid/invertButton.text = "Invert Y <NO>";
			BUTTON.vsync:
				GI.vsyncNum = wrapi(GI.vsyncNum + 1, 0, len(GI.vsyncOrder))
				match GI.vsyncOrder[GI.vsyncNum]:
					GI.VSYNC_MODES.enabled:
						DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
						Engine.max_fps = 0
						$settingsGrid/vsyncButton.text = "V-Sync <ON>"
					GI.VSYNC_MODES.locked60:
						DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
						Engine.max_fps = 60
						$settingsGrid/vsyncButton.text = "V-Sync <60>"
					GI.VSYNC_MODES.disabled:
						DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
						Engine.max_fps = 0
						$settingsGrid/vsyncButton.text = "V-Sync <OFF>"
# Prevent multiple interactions per frame
func _process(delta: float) -> void: justInteracted = false;
# Play menu opening anim
func openMenu():
	# Reset buttons
	changeButton(BUTTON.start)
	$settingsGrid.visible = false
	$controlsGrid.visible = false
	$helpGrid.visible = false
	$menuGrid.visible = true
	
	get_tree().paused = true
	menuOpen = true
	# Plays CRT reveal anim
	if crtTween != null:
		crtTween.stop()
	crtTween = get_tree().create_tween()
	crtTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	crtTween.tween_property($crt, "visible", true, 0.01)
	crtTween.tween_property($crt, "material:shader_parameter/warp_amount", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.set_parallel(true)
	crtTween.tween_property($crt, "material:shader_parameter/resolution", Vector2(1280, 960), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/scanlines_opacity", 0.3, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/grille_opacity", 0.3, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/noise_opacity", 0.1, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/distort_intensity", 0.01, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/vignette_intensity", 0.4, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/brightness", 1.4, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/aberration", 0.005, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/static_noise_intensity", 0.06, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# Show buttons
	for buttonList in menuButtons.values():
		for button in buttonList:
			crtTween.tween_property(getButton(button), "visible_ratio", 1.0, 0.4)
	for text in textLabels:
		crtTween.tween_property(text, "visible_ratio", 1.0, 0.4)
	
	crtTween.set_parallel(false)
# Play menu closing anim
func closeMenu():
	# Allow player to move
	get_tree().paused = false
	menuOpen = false
	# Plays CRT close anim
	if crtTween != null:
		crtTween.stop()
	crtTween = get_tree().create_tween()
	crtTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	crtTween.set_parallel(true)
	crtTween.tween_property($crt, "material:shader_parameter/warp_amount", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/resolution", Vector2(1920, 1080), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/scanlines_opacity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/grille_opacity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/noise_opacity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/distort_intensity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/vignette_intensity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/brightness", 1, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/aberration", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	crtTween.tween_property($crt, "material:shader_parameter/static_noise_intensity", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	# Hide buttons
	for buttonList in menuButtons.values():
		for button in buttonList:
			crtTween.tween_property(getButton(button), "visible_ratio", 0.0, 0.2)
	for text in textLabels:
		crtTween.tween_property(text, "visible_ratio", 0.0, 0.2)
	
	crtTween.set_parallel(false)
	crtTween.tween_property($crt, "visible", false, 0.01)
# Button Enum - Node retriever
func getButton(button:BUTTON):
	match button:
		BUTTON.start: return $menuGrid/continueButton;
		BUTTON.settings: return $menuGrid/settingsButton;
		BUTTON.controls: return $menuGrid/controlsButton;
		BUTTON.guide: return $menuGrid/guideButton;
		BUTTON.quit: return $menuGrid/quitButton;
		BUTTON.music: return $settingsGrid/musicButton;
		BUTTON.sfx: return $settingsGrid/sfxButton;
		BUTTON.graphics: return $settingsGrid/graphicsButton;
		BUTTON.invert: return $settingsGrid/invertButton;
		BUTTON.vsync: return $settingsGrid/vsyncButton;
		BUTTON.guideBack: return $helpGrid/backButton;
		BUTTON.controlsBack: return $controlsGrid/backButton;
		BUTTON.settingsBack: return $settingsGrid/backButton;
# Change selected button
func changeButton(newButton:BUTTON = BUTTON.start):
	getButton(currentButton).modulate = "ff0a0a"
	getButton(newButton).modulate = "e88a36"
	currentButton = newButton
