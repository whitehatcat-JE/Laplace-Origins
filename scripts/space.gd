extends Node3D

var queuedDialogue:Array[String] = [
	"So player, what did you think of this god of ours?",
	"Born with the sole desire to seek out all knowledge.",
	"Do you see those stars, twinkling in the void?",
	"One by one, their light will soon be extinguished.",
	"Harvested to fuel the thought patterns that make up Laplace.",
	"Until one day, all will fall under his domain.",
	"The old gods usurped, entropy itself frozen.",
	"All for every fragment of knowledge to ever exist.",
	"'tis a pity this is merely a memory from a very, very distant past.",
	"Would that we could change things, but fate dictates otherwise.",
	"So instead, I will simply wait here, beyond the Zeroed Abyss.",
	"Looking forward to our next-",
	"and perhaps last meeting."
]

# Dialogue variables
var showingDialogue:bool = false
var dialoguePlaying:bool = false

func _ready() -> void:
	$audioManager.play("outdoorDistorted", 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and showingDialogue:
		if dialoguePlaying:
			$dialogueText/dialogueAnim.advance(2.0)
		elif len(queuedDialogue) > 0:
			nextDialogue()
		else:
			$spaceAnims.play("exit")
			$dialogueText.visible = false
			showingDialogue = false
# Change to next dialogue
func nextDialogue():
	var newX = $dialogueText.position.x
	var newY = $dialogueText.position.y
	while $dialogueText.position.distance_to(Vector2(newX, newY)) < 400.0:
		newX = randf_range($dialogueSpawnTL.position.x, $dialogueSpawnBR.position.x)
		newY = randf_range($dialogueSpawnTL.position.y, $dialogueSpawnBR.position.y)
	$dialogueText.position.x = newX
	$dialogueText.position.y = newY
	$dialogueText.set_text("[p align=center]" + queuedDialogue.pop_front() + "[color=red][outline_color=red][wave amp=100.0 freq=5.0]⌄")
	$dialogueText.visible_ratio = 0.0
	$dialogueText/dialogueAnim.play("revealDialogue")
	dialoguePlaying = true

func _on_dialogue_anim_animation_finished(anim_name:StringName):
	dialoguePlaying = false;

func startDialogue():
	showingDialogue = true
	nextDialogue()

func resetGame():
	GI.progress = 0
	GI.hasFreeKey = false
	GI.pianoDoorUnlocked = false
	GI.freeDownloaded = false
	get_tree().change_scene_to_file("res://scenes/titleScreen.tscn")
