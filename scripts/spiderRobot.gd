extends CharacterBody2D

const MAX_HEALTH:int = 5
var SPEED:float = 100.0 * randf_range(0.9, 1.1)

var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false

@onready var maxHealthSize:float = $health.size.x

func _physics_process(delta):
	if !active: return;
	if dead:
		if !$explosionParticles.emitting: queue_free();
	velocity = Vector2(SPEED, 0).rotated(position.angle_to_point(GI.playerPos2D))

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

func _on_bullet_scanner_area_entered(area):
	area.kill()
	health -= 1
	$health.visible = true
	if health == 0: kill();
	$health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH)
