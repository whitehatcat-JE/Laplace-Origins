extends CharacterBody2D

signal damage

const SPEED:float = 200.0
const FIRING_SPEED:float = 0.2

var timeSinceLastBullet:float = 0.0
var alive:bool = false

@onready var bulletScene:PackedScene = preload("res://objects/bullet.tscn")

func spawnBullet():
	var dir:Vector2 = Input.get_vector("shooterFireLeft", "shooterFireRight", "shooterFireUp", "shooterFireDown")
	if dir.is_zero_approx(): return;
	var bullet = bulletScene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = position
	bullet.direction = dir

func _physics_process(delta):
	if !GI.shooterActive or !GI.inOS or !alive: return;
	timeSinceLastBullet += delta
	var inputDir = Input.get_vector("shooterMoveLeft", "shooterMoveRight", "shooterMoveUp", "shooterMoveDown")
	velocity = inputDir * SPEED
	
	move_and_slide()
	
	GI.playerPos2D = position
	
	if (Input.is_action_pressed("shooterFireLeft") or
		Input.is_action_pressed("shooterFireRight") or
		Input.is_action_pressed("shooterFireUp") or
		Input.is_action_pressed("shooterFireDown")) and timeSinceLastBullet > FIRING_SPEED:
		timeSinceLastBullet = 0.0
		spawnBullet()

func _on_enemy_scanner_body_entered(body):
	if !alive: return;
	body.kill()
	emit_signal("damage")

func _on_enemy_scanner_area_entered(area):
	if !alive: return;
	area.kill()
	emit_signal("damage")
