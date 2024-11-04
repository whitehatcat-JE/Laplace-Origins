extends Node2D
# Notifies home scene to unlock piano room
signal unlockDoor
# Hides basement key instance
func hideKey():
	$basementInteractionButtons/key.position.y = 10000
	$basementLevel/basementInteractionPoints/basementKeyInteraction.position.y = 10000
	$basementLevel/basementKey.visible = false
# Shows interaction specific dialogue
func showDialogue(dialogueName:String):
	match dialogueName:
		"door": # Piano room door dialogue
			if GI.pianoDoorUnlocked:
				$dialoguePopup/dialogueText.text = "Wrong Dimension"
				$deniedSFX.play()
			elif GI.hasFreeKey:
				$dialoguePopup/dialogueText.text = "Door Unlocked"
				emit_signal("unlockDoor")
			else:
				$dialoguePopup/dialogueText.text = "Missing Key"
				$deniedSFX.play()
		"key": # Basement key dialogue
			$dialoguePopup/dialogueText.text = "Wrong Dimension"
			$deniedSFX.play()
		"laplace": # City dialogue
			$dialoguePopup/dialogueText.text = "Wrong Dimension"
			$deniedSFX.play()
	# Reveal selected dialogue
	$dialoguePopup/dialogueAnim.play("appear")
	for child in getAllChildren($groundInteractionButtons):
		if child is Area2D:
			child.position.y += 10000
	$player.playerUnlocked = false # Lock player
# Get all sub-children of node
func getAllChildren(startingNode, currentChildren:Array = []):
	for child in startingNode.get_children():
		currentChildren.append_array(getAllChildren(child))
		currentChildren.append(child)
	return currentChildren
# Hide dialogue
func _on_dialogue_anim_animation_finished(anim_name):
	$player.playerUnlocked = true
	for child in getAllChildren($groundInteractionButtons):
		if child is Area2D:
			child.position.y -= 10000
# Show / hide door button 
func _on_door_body_entered(body): $groundInteractionButtons/door/buttonAnims.play("show");
func _on_door_body_exited(body): $groundInteractionButtons/door/buttonAnims.play("hide");
# Enter basement
func _on_staircase_down_body_entered(body):
	$groundFloorLevel.position.y += 10000
	$groundInteractionButtons.position.y += 10000
	$basementLevel.position.y -= 10000
	$basementInteractionButtons.position.y -= 10000
# Enter ground floor
func _on_staircase_up_body_entered(body):
	$groundFloorLevel.position.y -= 10000
	$groundInteractionButtons.position.y -= 10000
	$basementLevel.position.y += 10000
	$basementInteractionButtons.position.y += 10000
# Show / hide basement key button
func _on_basement_key_interaction_body_entered(body): $basementInteractionButtons/key/buttonAnims.play("show");
func _on_basement_key_interaction_body_exited(body): $basementInteractionButtons/key/buttonAnims.play("hide");
# Teleport to city
func _on_city_entrance_body_entered(body: Node2D) -> void:
	$basementLevel.position.y += 10000
	$basementInteractionButtons.position.y += 10000
	$cityLevel.position.y -= 10000
	$cityInteractionButtons.position.y -= 10000
	$player.global_position = $cityLevel/playerPos.global_position
	$player.yLocked = true
# Teleport to basement
func _on_exit_interaction_body_entered(body: Node2D) -> void:
	$basementLevel.position.y -= 10000
	$basementInteractionButtons.position.y -= 10000
	$cityLevel.position.y += 10000
	$cityInteractionButtons.position.y += 10000
	$player.global_position = $basementLevel/playerPos.global_position
	$player.yLocked = false
# Show / hide Laplace button
func _on_laplace_interaction_body_entered(body: Node2D) -> void: $cityInteractionButtons/laplace/buttonAnims.play("show");
func _on_laplace_interaction_body_exited(body: Node2D) -> void: $cityInteractionButtons/laplace/buttonAnims.play("hide");
