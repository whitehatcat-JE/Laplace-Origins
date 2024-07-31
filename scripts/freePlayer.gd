extends CharacterBody2D
# Constants
const SPEED:float = 200.0
# Player movement
var playerUnlocked:bool = true
func _physics_process(delta) -> void:
	if !GI.freeActive or !GI.inOS or !playerUnlocked: return; # Stop player from moving if game not focused or player dead
	# Move in inputted direction
	velocity = Input.get_vector("shooterMoveLeft", "shooterMoveRight", "shooterMoveUp", "shooterMoveDown") * SPEED
	move_and_slide()
