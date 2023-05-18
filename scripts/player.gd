extends CharacterBody3D

signal interacted(interactionName:String)

const PLAYER_SPEED:float = 4
const MOUSE_SENSITIVITY:float = 0.15
const DECELERATION:float = 20.0

var cameraAngle:float = 0
var disabled:bool = false

var unlockedInteractions = ["monitor", "passcode"]

@onready var interactCast = $head/cam/interactCast
@onready var collisionCast = $head/cam/collisionCast
@onready var HUDcrosshair = $HUD/crosshair
@onready var HUDinteract = $HUD/interact
@onready var HUDlock = $HUD/lock

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Used for mouse movement detection
func _input(event):
	if disabled: return;
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		var change = -event.relative.y * MOUSE_SENSITIVITY
		if change + cameraAngle < 85 and change + cameraAngle > -85:
			$head/cam.rotate_x(deg_to_rad(change))
			cameraAngle += change
	elif Input.is_action_just_pressed("interact") and HUDinteract.visible:
		emit_signal("interacted", interactCast.get_collider().interactionName)

func _physics_process(delta):
	if disabled:
		$bobAnim.speed_scale = 0.1
		return
	HUDinteract.visible = false
	HUDcrosshair.visible = false
	HUDlock.visible = false
	if interactCast.is_colliding():
		var curPos = interactCast.global_transform.origin
		var colDis = 100000.0
		if collisionCast.is_colliding():
			colDis = collisionCast.get_collision_point().distance_to(curPos)
		var intDis = interactCast.get_collision_point().distance_to(curPos)
		
		if intDis < colDis:
			var intPos = interactCast.get_collider().global_transform.origin
			if interactCast.get_collider().minDistance < intPos.distance_to(curPos):
				HUDcrosshair.visible = true
			elif interactCast.get_collider().interactionName in unlockedInteractions:
				HUDinteract.visible = true
			else:
				HUDlock.visible = true
		
	var aim = get_global_transform().basis
	var direction:Vector3 = Vector3(0, -1, 0)
	
	if Input.is_action_pressed("moveLeft"): direction -= aim.x
	if Input.is_action_pressed("moveRight"): direction += aim.x
	if Input.is_action_pressed("moveForward"): direction -= aim.z
	if Input.is_action_pressed("moveBackward"): direction += aim.z
	
	if direction.dot(velocity) == 0 and velocity.length() > 0.1:
		velocity -= velocity * DECELERATION * delta
	else:
		if direction.dot(velocity) > 0: $bobAnim.speed_scale = 1.0
		else: $bobAnim.speed_scale = 0.1
		velocity = direction.normalized() * PLAYER_SPEED
	move_and_slide()
