extends Node3D
# Signals
signal exitSchrodinger
# State variables
var isFocused:bool = false
var inCutscene:bool = false
# Dialogue variables
var showingDialogue:bool = false
var dialoguePlaying:bool = false

var queuedDialogue:Array[String] = [
	"Ah player! It is my pleasure to meet you again.",
	"Or is this our first meeting?",
	"That knowledge lies within you alone I'm afraid.",
	"Either way, I'm glad you found my gift on time.",
	"A memory from before the halt of entropy.",
	"Now, on the off-chance this is our first meeting, please allow me to leave you my name.",
	"I am Schrodinger, a humble overseer of the forgotten.",
	"And Archangel of Laplace.",
	"Now, it's been a pleasure talking to you, but any longer and Laplace may catch wind.",
	"Au revoir."
]
# Background pillar nodes
@onready var pillars:Array[Sprite3D] = [$pillar1, $pillar2, $pillar3, $pillar4, $pillar5, $pillar6, $pillar7, $pillar8, $pillar9, $pillar10]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isFocused or !GI.shooterActive or !GI.inOS or inCutscene: # Check whether scene is in focus
		$player.disabled = true
		if !(!isFocused or !GI.shooterActive or !GI.inOS) and inCutscene:
			get_parent().render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			get_parent().render_target_update_mode = SubViewport.UPDATE_DISABLED
	elif $player.disabled: # Focus player
		get_parent().render_target_update_mode = SubViewport.UPDATE_ALWAYS
		$player.disabled = false
	# Update pillar positions
	for pillarIdx in range(len(pillars)):
		var rectPos:Rect2 = pillars[pillarIdx].get_region_rect()
		rectPos.position.y += 10.0 * delta * -(float(pillarIdx - 5) / 5.0 if pillarIdx != 5 else 1.0)
		pillars[pillarIdx].set_region_rect(rectPos)
	# Dialogue interactions
	if isFocused and GI.shooterActive and GI.inOS and showingDialogue:
		if Input.is_action_just_pressed("interact"):
			if dialoguePlaying:
				$player/dialogueText/dialogueAnim.advance(2.0)
			elif len(queuedDialogue) > 0:
				nextDialogue()
			else:
				if GI.steamLoaded: Steam.setAchievement("SH_SCHRODINGER");
				emit_signal("exitSchrodinger")
# Trigger cutscene anim
func _on_pavilion_scanner_body_entered(body):
	inCutscene = true
	$cutsceneAnims.play("introduceSchrodinger")
# Change to next dialogue
func nextDialogue():
	$player/dialogueText.set_text("[p align=center]" + queuedDialogue.pop_front() + "[color=red][outline_color=red][wave amp=100.0 freq=5.0]⌄")
	$player/dialogueText.visible_ratio = 0.0
	$player/dialogueText/dialogueAnim.play("revealDialogue")
	dialoguePlaying = true
# Start dialogue
func _on_cutscene_anims_animation_finished(anim_name):
	if anim_name == "introduceSchrodinger" and len(queuedDialogue) > 0:
		showingDialogue = true
		nextDialogue()
# End dialogue
func _on_dialogue_anim_animation_finished(anim_name): dialoguePlaying = false;
