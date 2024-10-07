extends Node3D

signal exitSchrodinger

var isFocused:bool = false
var inCutscene:bool = false

var showingDialogue:bool = false
var dialoguePlaying:bool = false

var queuedDialogue:Array[String] = [
	"I see you’ve found my gift, player.",
	"A memory of a now long forgotten time.",
	". . .",
	"Or not. . .",
	"Drat, it seems this program released ahead of schedule.",
	"First the whole Pacella game fiasco, and now this. . .",
	". . .",
	"Ah, my apologies, you must be rather confused.",
	"Would you mind pretending you never saw this?",
	"I'd rather Laplace didn't find out about this side project of mine just yet.",
	"Oh, but before I depart, let me at least leave you my name.",
	"I am Schrodinger, a humble overseer of the forgotten.",
	"Now, it's been a pleasure meeting you, but any longer and Laplace might notice us.",
	"Au revoir."
]

@onready var pillars:Array[Sprite3D] = [$pillar1, $pillar2, $pillar3, $pillar4, $pillar5, $pillar6, $pillar7, $pillar8, $pillar9, $pillar10]

func _ready():
	return
	GI.shooterActive = true
	GI.inOS = true
	isFocused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isFocused or !GI.shooterActive or !GI.inOS or inCutscene:
		$player.disabled = true
		if !(!isFocused or !GI.shooterActive or !GI.inOS) and inCutscene:
			get_parent().render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			get_parent().render_target_update_mode = SubViewport.UPDATE_DISABLED
	elif $player.disabled:
		get_parent().render_target_update_mode = SubViewport.UPDATE_ALWAYS
		$player.disabled = false
	for pillarIdx in range(len(pillars)):
		var rectPos:Rect2 = pillars[pillarIdx].get_region_rect()
		rectPos.position.y += 10.0 * delta * -(float(pillarIdx - 5) / 5.0 if pillarIdx != 5 else 1.0)
		pillars[pillarIdx].set_region_rect(rectPos)
	if isFocused and GI.shooterActive and GI.inOS and showingDialogue:
		if Input.is_action_just_pressed("interact"):
			if dialoguePlaying:
				$player/dialogueText/dialogueAnim.advance(2.0)
			elif len(queuedDialogue) > 0:
				nextDialogue()
			else:
				emit_signal("exitSchrodinger")

func _on_pavilion_scanner_body_entered(body):
	inCutscene = true
	$cutsceneAnims.play("introduceSchrodinger")

func nextDialogue():
	$player/dialogueText.set_text("[p align=center]" + queuedDialogue.pop_front() + "[color=red][outline_color=red][wave amp=100.0 freq=5.0]⌄")
	$player/dialogueText.visible_ratio = 0.0
	$player/dialogueText/dialogueAnim.play("revealDialogue")
	dialoguePlaying = true

func _on_cutscene_anims_animation_finished(anim_name):
	if anim_name == "introduceSchrodinger" and len(queuedDialogue) > 0:
		showingDialogue = true
		nextDialogue()


func _on_dialogue_anim_animation_finished(anim_name):
	dialoguePlaying = false
