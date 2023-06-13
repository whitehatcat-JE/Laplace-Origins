extends Node3D
# State variables
var curSong:String = "none"
var previousSong:String = "none"
var maxVolume:float = 0
# Audio transition tweens
var fadeOutTween:Tween
var fadeInTween:Tween
# Check if player currently in minigame
func _process(_delta) -> void:
	if (GI.shooterActive and GI.inOS) and curSong != "singularity": # Play minigame music
		previousSong = curSong
		play("singularity")
	elif !(GI.shooterActive and GI.inOS) and curSong == "singularity": # Stop minigame music
		play(previousSong)
# Play requested song
func play(songName:String) -> void:
	if curSong == songName: return; # Stops same song from playing twice at once
	if fadeOutTween != null: # Stops song fade out transition
		if fadeOutTween.is_running(): fadeOutTween.stop();
	if fadeInTween != null: # Stops current song fade in transition
		if fadeInTween.is_running(): fadeInTween.stop();
	if get_node_or_null(curSong) != null: # Fades out current song
		fadeOutTween = get_tree().create_tween()
		fadeOutTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Stops tween from stopping whenever menu opened
		fadeOutTween.tween_property(get_node(curSong), "volume_db", -20, 1).set_trans(Tween.TRANS_SINE) # Gradually lowers song volume
		fadeOutTween.tween_property(get_node(curSong), "playing", false, 0.1).set_trans(Tween.TRANS_SINE) # Stops song after volume lowered
	curSong = songName
	if get_node_or_null(curSong) != null:  # Fades in newly requested song
		fadeInTween = get_tree().create_tween()
		fadeInTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # Stops tween from stopping whenever menu opened
		fadeInTween.tween_property(get_node(curSong), "playing", true, 0.1).set_trans(Tween.TRANS_SINE) # Gradually lowers song volume
		fadeInTween.tween_property(get_node(curSong), "volume_db", maxVolume, 1).set_trans(Tween.TRANS_SINE) # Stops song after volume lowered
# Updates song volume whenever volume changed in menu
func changeVolume(newVolume:int) -> void:
	if newVolume == -20: newVolume = -80; # Mutes song
	maxVolume = newVolume
	if get_node_or_null(curSong) == null: return;
	get_node(curSong).volume_db = newVolume # Updates volume
