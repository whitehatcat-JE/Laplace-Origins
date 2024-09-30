extends Node2D

signal unlockDoor

func hideKey():
	$basementInteractionButtons/key.position.y = 10000
	$basementLevel/basementInteractionPoints/basementKeyInteraction.position.y = 10000
	$basementLevel/basementKey.visible = false

func showDialogue(dialogueName:String):
	match dialogueName:
		"door":
			if GI.pianoDoorUnlocked:
				$dialoguePopup/dialogueText.text = "Wrong Dimension"
			elif GI.hasFreeKey:
				$dialoguePopup/dialogueText.text = "Door Unlocked"
				emit_signal("unlockDoor")
			else:
				$dialoguePopup/dialogueText.text = "Missing Key"
		"key":
			$dialoguePopup/dialogueText.text = "Wrong Dimension"
		"laplace":
			$dialoguePopup/dialogueText.text = "Wrong Dimension"
	$dialoguePopup/dialogueAnim.play("appear")
	for child in getAllChildren($groundInteractionButtons):
		if child is Area2D:
			child.position.y += 10000
	$player.playerUnlocked = false

func getAllChildren(startingNode, currentChildren:Array = []):
	for child in startingNode.get_children():
		currentChildren.append_array(getAllChildren(child))
		currentChildren.append(child)
	return currentChildren

func _on_dialogue_anim_animation_finished(anim_name):
	$player.playerUnlocked = true
	for child in getAllChildren($groundInteractionButtons):
		if child is Area2D:
			child.position.y -= 10000

func _on_door_body_entered(body):
	$groundInteractionButtons/door/buttonAnims.play("show")
func _on_door_body_exited(body):
	$groundInteractionButtons/door/buttonAnims.play("hide")

func _on_staircase_down_body_entered(body):
	$groundFloorLevel.position.y += 10000
	$groundInteractionButtons.position.y += 10000
	$basementLevel.position.y -= 10000
	$basementInteractionButtons.position.y -= 10000

func _on_staircase_up_body_entered(body):
	$groundFloorLevel.position.y -= 10000
	$groundInteractionButtons.position.y -= 10000
	$basementLevel.position.y += 10000
	$basementInteractionButtons.position.y += 10000

func _on_basement_key_interaction_body_entered(body):
	$basementInteractionButtons/key/buttonAnims.play("show")
func _on_basement_key_interaction_body_exited(body):
	$basementInteractionButtons/key/buttonAnims.play("hide")

func _on_city_entrance_body_entered(body: Node2D) -> void:
	$basementLevel.position.y += 10000
	$basementInteractionButtons.position.y += 10000
	$cityLevel.position.y -= 10000
	$cityInteractionButtons.position.y -= 10000
	$player.global_position = $cityLevel/playerPos.global_position
	$player.yLocked = true

func _on_exit_interaction_body_entered(body: Node2D) -> void:
	$basementLevel.position.y -= 10000
	$basementInteractionButtons.position.y -= 10000
	$cityLevel.position.y += 10000
	$cityInteractionButtons.position.y += 10000
	$player.global_position = $basementLevel/playerPos.global_position
	$player.yLocked = false

func _on_laplace_interaction_body_entered(body: Node2D) -> void:
	$cityInteractionButtons/laplace/buttonAnims.play("show")

func _on_laplace_interaction_body_exited(body: Node2D) -> void:
	$cityInteractionButtons/laplace/buttonAnims.play("hide")
