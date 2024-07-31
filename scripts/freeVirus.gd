extends Node2D

var hasKey:bool = false
var doorUnlocked:bool = false

func showDialogue(dialogueName:String):
	match dialogueName:
		"door":
			if doorUnlocked:
				$dialoguePopup/dialogueText.text = "Wrong Dimension"
			elif hasKey:
				doorUnlocked = true
				$dialoguePopup/dialogueText.text = "Door Unlocked"
			else:
				hasKey = true
				$dialoguePopup/dialogueText.text = "Missing Key"
		"key":
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
