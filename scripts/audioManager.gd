extends Node3D
# State variables
var curSong:String = "none"
var previousSong:String = "none"
var maxVolume:float = 0
# Audio transition tweens
var fadeOutTween:Tween
var fadeInTween:Tween
# Updates volume on load
func _ready(): changeVolume(-20 + GI.musicVolume * 2);

# Check if player currently in minigame
func _process(_delta) -> void:
	# Plays music based on which minigame the player is interacting with
	if (GI.shooterActive and GI.inOS):
		if GI.schrodingerActive and curSong != "schrodinger":
			if curSong not in ["singularity", "schrodinger", "laplace"]: previousSong = curSong;
			if curSong == "singularity": play("schrodinger", 4.0);
			else: play("schrodinger", 1.0);
		elif !GI.schrodingerActive and GI.laplaceActive and curSong != "laplace":
			if curSong not in ["singularity", "schrodinger", "laplace"]: previousSong = curSong;
			play("laplace")
		elif !GI.schrodingerActive and !GI.laplaceActive and curSong != "singularity":
			if curSong not in ["singularity", "schrodinger", "laplace"]: previousSong = curSong;
			play("singularity")
	elif !(GI.shooterActive and GI.inOS) and curSong in ["singularity", "schrodinger"]: # Stop minigame music
		play(previousSong)
	# Plays slimybird specific music
	if GI.slimyBirdActive and GI.inOS and curSong != "slimyBird":
		previousSong = curSong
		play("slimyBird")
	elif !(GI.slimyBirdActive and GI.inOS) and curSong == "slimyBird": # Resets minigame music
		play(previousSong)
# Play requested song
func play(songName:String, fadeTime:float = 1.0) -> void:
	if curSong == songName: return; # Stops same song from playing twice at once
	if fadeOutTween != null: # Stops song fade out transition
		if fadeOutTween.is_running(): fadeOutTween.custom_step(10.0);
	if fadeInTween != null: # Stops current song fade in transition
		if fadeInTween.is_running(): fadeInTween.custom_step(10.0);
	if get_node_or_null(curSong) != null: # Fades out current song
		fadeOutTween = get_tree().create_tween()
		fadeOutTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Stops tween from stopping whenever menu opened
		if get_node(curSong).volume_db > -20:
			fadeOutTween.tween_property(get_node(curSong), "volume_db", -20, fadeTime).set_trans(Tween.TRANS_SINE) # Gradually lowers song volume
		fadeOutTween.tween_property(get_node(curSong), "playing", false, 0.1).set_trans(Tween.TRANS_SINE) # Stops song after volume lowered
	curSong = songName
	if get_node_or_null(curSong) != null:  # Fades in newly requested song
		fadeInTween = get_tree().create_tween()
		fadeInTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Stops tween from stopping whenever menu opened
		fadeInTween.tween_property(get_node(curSong), "playing", true, 0.1).set_trans(Tween.TRANS_SINE) # Gradually lowers song volume
		fadeInTween.tween_property(get_node(curSong), "volume_db", maxVolume, fadeTime).set_trans(Tween.TRANS_SINE) # Stops song after volume lowered
# Updates song volume whenever volume changed in menu
func changeVolume(newVolume:int) -> void:
	if newVolume == -20: newVolume = -80; # Mutes song
	maxVolume = newVolume
	if get_node_or_null(curSong) == null: return;
	get_node(curSong).volume_db = newVolume # Updates volume
