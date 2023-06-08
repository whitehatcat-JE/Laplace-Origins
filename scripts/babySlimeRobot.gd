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
		return
	if velocity.length() < 10.0:
		velocity = Vector2(JUMP_SPEED, 0).rotated(position.angle_to_point(GI.playerPos2D))
	velocity -= velocity * delta * DRAG
	move_and_slide()

func kill():
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	set_collision_layer_value(7, false)
	set_collision_mask_value(1, false)
	$sprite.visible = false
	$explosionParticles.emitting = true
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.pitch_scale *= randf_range(0.8, 1.2)
	$die.play()

func activate():
	active = true
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)

func _on_bullet_scanner_area_entered(area):
	area.kill()
	health -= 1
	if health == 0: kill();
