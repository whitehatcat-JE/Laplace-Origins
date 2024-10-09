extends CharacterBody3D
# Signals
signal interacted(interactionName:String)
signal droppedEvent(event:InputEvent)
# Constants
@export var PLAYER_SPEED:float = 3
const MOUSE_SENSITIVITY:float = 0.15
const DECELERATION:float = 20.0
# State variables
var cameraAngle:float = 0
var unlockedInteractions:Array[String] = ["monitor", "passcode", "crt", "piano", "notepad", "freeKey"]
var currentGroundType:int = 0
# Export variables
@export var lockYRot:bool = false
@export var disabled:bool = false
@export var canMove:bool = true
# Nodes
@onready var groundTypes:Dictionary = {9:$footstepsWood, 17:$footstepsGravel, 33:$footstepsGrass, 65:$footstepsStone, 129:$footstepsFlesh}

@onready var interactCast:Node = $head/cam/interactCast
@onready var collisionCast:Node = $head/cam/collisionCast
@onready var HUDcrosshair:Node = $HUD/crosshair
@onready var HUDinteract:Node = $HUD/interact
@onready var HUDlock:Node = $HUD/lock

# Disable mouse visibility
func _ready() -> void: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
# Input manager
func _input(event) -> void:
	if disabled:
		emit_signal("droppedEvent", event)
		return
	if event is InputEventMouseMotion: # Used for mouse movement detection
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		var change:float = (1 if GI.invertY else -1) * event.relative.y * MOUSE_SENSITIVITY
		if !lockYRot:
			if change + cameraAngle > 85:
				$head/cam.rotate_x(deg_to_rad(85 - cameraAngle))
				cameraAngle = 85
			elif change + cameraAngle < -85:
				$head/cam.rotate_x(deg_to_rad(-(85 + cameraAngle)))
				cameraAngle = -85
			else:
				$head/cam.rotate_x(deg_to_rad(change))
				cameraAngle += change
		else:
			if change + cameraAngle > 60:
				$head/cam.rotate_x(deg_to_rad(60 - cameraAngle))
				cameraAngle = 60
			elif change + cameraAngle < -85:
				$head/cam.rotate_x(deg_to_rad(-(85 + cameraAngle)))
				cameraAngle = -85
			else:
				$head/cam.rotate_x(deg_to_rad(change))
				cameraAngle += change
	elif Input.is_action_just_pressed("interact") and HUDinteract.visible: # Interact with object looking at
		if interactCast.get_collider() == null: return;
		emit_signal("interacted", interactCast.get_collider().interactionName)
# Player movement & interaction updates
func _physics_process(delta) -> void:
	# Update interaction state
	HUDinteract.visible = false
	HUDcrosshair.visible = false
	HUDlock.visible = false
	if disabled or !canMove: # Prevents player from moving when disabled
		$bobAnim.speed_scale = 0.1
		if currentGroundType != 0:
			groundTypes[currentGroundType].stop()
			currentGroundType = 0
		return
	if interactCast.is_colliding(): # Check if player is looking at interactable object
		# Calculate distance to object from player
		var curPos:Vector3 = interactCast.global_transform.origin
		var colDis:float = 100000.0
		if collisionCast.is_colliding():
			colDis = collisionCast.get_collision_point().distance_to(curPos)
		var intDis:float = interactCast.get_collision_point().distance_to(curPos)
		
		if intDis < colDis: # Check if player is close enough to interact with object
			var intPos:Vector3 = interactCast.get_collider().global_transform.origin
			if interactCast.get_collider().minDistance < intPos.distance_to(curPos):
				HUDcrosshair.visible = true
			elif interactCast.get_collider().interactionName in unlockedInteractions: # Check player has unlocked object
				if interactCast.get_collider().interactionName == "router" and GI.progress not in [1, 6]:
					unlockedInteractions.erase("router")
					HUDlock.visible = true
				else:
					HUDinteract.visible = true
			else: HUDlock.visible = true;
	# Create movement matrix
	var aim:Basis = get_global_transform().basis
	var direction:Vector3 = Vector3(0, -1, 0)
	if is_on_floor():
		direction.y = 0.0
	
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
