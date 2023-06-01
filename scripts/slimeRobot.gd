extends CharacterBody2D

const MAX_HEALTH:int = 3
const DRAG:float = 4.0
var JUMP_SPEED:float = 300.0 * randf_range(0.9, 1.1)

var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false

@onready var maxHealthSize:float = $health.size.x
@onready var babySlime:PackedScene = preload("res://objects/babySlimeRobot.tscn")

func spawnBaby():
	var newBaby:Node = babySlime.instantiate()
	get_parent().add_child(newBaby)
	get_parent().allEnemies.append(newBaby)
	newBaby.position = position
	newBaby.activate()

func _physics_process(delta):
	if !active: return;
	if dead:
		if !$explosionParticles.emitting: queue_free();
	if velocity.length() < 10.0:
		velocity = Vector2(JUMP_SPEED, 0).rotated(randf_range(-PI, PI))
	velocity -= velocity * delta * DRAG
	move_and_slide()

func kill():
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	$health.visible = false
	$explosionParticles.emitting = true

func activate():
	active = true
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)
	$babySpawnTimer.start()

func _on_bullet_scanner_area_entered(area):
	area.kill()
	health -= 1
	$health.visible = true
	if health == 0:
		get_parent().score += 100
		kill()
	$health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH)

func _on_baby_spawn_timer_timeout():
	if !dead: spawnBaby();
