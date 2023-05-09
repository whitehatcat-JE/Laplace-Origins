extends CharacterBody3D

const PLAYER_SPEED:float = 4
const MOUSE_SENSITIVITY:float = 0.15
const DECELERATION:float = 20.0

var cameraAngle:float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Used for mouse movement detection
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		var change = -event.relative.y * MOUSE_SENSITIVITY
		if change + cameraAngle < 85 and change + cameraAngle > -85:
			$head/cam.rotate_x(deg_to_rad(change))
			cameraAngle += change

func _physics_process(delta):
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
