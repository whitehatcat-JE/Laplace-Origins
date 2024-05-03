extends CharacterBody3D
# Constants
const PLAYER_SPEED:float = 4
const MOUSE_SENSITIVITY:float = 0.15
const DECELERATION:float = 20.0
# State variables
var cameraAngle:float = 0
var currentGroundType:int = 0
# Export variables
@export var disabled:bool = false
# Nodes
@onready var groundTypes:Dictionary = {9:$footstepsWood, 17:$footstepsGravel}

@onready var interactCast:Node = $head/cam/interactCast
@onready var collisionCast:Node = $head/cam/collisionCast

func _input(event):
	_on_player_dropped_event(event)

# Player movement & interaction updates
func _physics_process(delta) -> void:
	if disabled: # Prevents player from moving when disabled
		$bobAnim.speed_scale = 0.1
		if currentGroundType != 0:
			groundTypes[currentGroundType].stop()
			currentGroundType = 0
		return
	# Create movement matrix
	var aim:Basis = get_global_transform().basis
	var direction:Vector3 = Vector3(0, -1, 0)
	
	if Input.is_action_pressed("moveLeft"): direction -= aim.x
	if Input.is_action_pressed("moveRight"): direction += aim.x
	if Input.is_action_pressed("moveForward"): direction -= aim.z
	if Input.is_action_pressed("moveBackward"): direction += aim.z
	# Move player in calculated direction
	if direction.dot(velocity) == 0 and velocity.length() > 0.1:
		velocity -= velocity * DECELERATION * delta
	else:
		if direction.dot(velocity) > 0: $bobAnim.speed_scale = 1.0;
		else: $bobAnim.speed_scale = 0.1;
		velocity = direction.normalized() * PLAYER_SPEED
	move_and_slide()
	# Footstep audios
	if $floorCast.is_colliding() and direction.dot(velocity) > 0:
		var groundType:int = $floorCast.get_collider().get_collision_layer()
		if groundType in groundTypes.keys() and currentGroundType != groundType:
			if currentGroundType != 0: groundTypes[currentGroundType].stop();
			groundTypes[groundType].play()
			currentGroundType = groundType
	elif currentGroundType != 0:
		groundTypes[currentGroundType].stop()
		currentGroundType = 0


func _on_player_dropped_event(event):
	if disabled: return;
	if event is InputEventMouseMotion: # Used for mouse movement detection
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		var change:float = (1 if GI.invertY else -1) * event.relative.y * MOUSE_SENSITIVITY
		if change + cameraAngle > 85:
			$head/cam.rotate_x(deg_to_rad(85 - cameraAngle))
			cameraAngle = 85
		elif change + cameraAngle < -85:
			$head/cam.rotate_x(deg_to_rad(-(85 + cameraAngle)))
			cameraAngle = -85
		else:
			$head/cam.rotate_x(deg_to_rad(change))
			cameraAngle += change
