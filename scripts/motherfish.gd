extends CharacterBody2D

const MAX_HEALTH:int = 6

var health:int = MAX_HEALTH
var dead:bool = false
var active:bool = false

@onready var maxHealthSize:float = $sprite/health.size.x
@onready var bullet:PackedScene = preload("res://objects/enemyBullet.tscn")

func _ready():
	await get_tree().create_timer(0.1).timeout
	$hitbox.set_deferred("disabled", false)
	$bulletScanner/hitbox.set_deferred("disabled", false)

func _physics_process(delta) -> void:
	if dead and !$explosionParticles.emitting and !$die.is_playing(): queue_free();
	$bulletPivot.look_at(GI.playerPos2D)

func kill() -> void:
	dead = true
	$hitbox.set_deferred("disabled", true)
	$bulletScanner/hitbox.set_deferred("disabled", true)
	$sprite.visible = false
	$explosionParticles.emitting = true
	$bulletTimer.stop()
	$die.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$die.play()

func activate() -> void:
	$bulletTimer.start()

func _on_bullet_scanner_area_entered(area) -> void:
	area.kill()
	health -= 1
	$sprite/health.visible = true
	if health == 0:
		get_parent().score += 750
		kill()
	$sprite/health.size.x = maxHealthSize * float(health) / float(MAX_HEALTH)

func createBullet() -> Node:
	var newBullet:Node = bullet.instantiate()
	get_parent().add_child(newBullet)
	get_parent().allEnemies.append(newBullet)
	newBullet.position = $bulletPivot.global_position
	return newBullet

func applyVelocity(subject, targetDir) -> void:
	subject.direction = Vector2(1, 0).rotated(
		subject.position.angle_to_point(targetDir))

func _on_bullet_timer_timeout() -> void:
	if dead: return;
	$shot.volume_db = (10 - GI.sfxVolume) * 2 if GI.sfxVolume > 0 else -80
	$shot.play()
	if randf_range(0, 1) < 0.33:
		$bulletPivot.rotation_degrees = 0.0
		for dir in $bulletPivot.get_children():
			applyVelocity(createBullet(), dir.global_position)
		return
	$bulletPivot.look_at(GI.playerPos2D)
	if randf_range(0, 1) < 0.5:
		applyVelocity(createBullet(), $bulletPivot/nTarget.global_position)
		applyVelocity(createBullet(), $bulletPivot/neTarget.global_position)
		applyVelocity(createBullet(), $bulletPivot/nwTarget.global_position)
	else:
		for bulletNum in range(3):
			if dead: return;
			applyVelocity(createBullet(), $bulletPivot/nTarget.global_position)
			await get_tree().create_timer(0.1).timeout
