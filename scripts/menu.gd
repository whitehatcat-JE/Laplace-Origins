extends Control

const SCROLL_SPEED:float = 5.0

var menuOpen:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if menuOpen:
			visible = false
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			visible = true
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		menuOpen = !menuOpen
	$backgroundTrunk.region_rect.position.y += delta * SCROLL_SPEED
