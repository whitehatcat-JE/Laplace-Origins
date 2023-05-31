extends CharacterBody2D

const MAX_HEALTH:int = 1
const DRAG:float = 4.0

var JUMP_SPEED:float = 150.0 * randf_range(0.9, 1.1)

var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false

func _physics_process(delta):
	if !active: return;
	if dead:
		if !$explosionParticles.emitting: queue_free();
	if velocity.length() < 10.0:
		velocity = Vector2(JUMP_SPEED, 0).rotated(position.angle_to_point(GI.playerPos2D))
	velocity -= velocity * delta * DRAG
	move_and_slide()

func kill():
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	$explosionParticles.emitting = true

func activate():
	active = true
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)

func _on_bullet_scanner_area_entered(area):
	area.kill()
	health -= 1
	if health == 0: kill();
