extends Node3D
# State variables
var curSong:String = "none"
var previousSong:String = "none"
var maxVolume:float = 0
# Audio transition tweens
var fadeOutTween:Tween
var fadeInTween:Tween
# Check if player currently in minigame
func _process(delta) -> void:
	if (GI.shooterActive and GI.inOS) and curSong != "singularity": # Play minigame music
		previousSong = curSong
		play("singularity")
	elif !(GI.shooterActive and GI.inOS) and curSong == "singularity": # Stop minigame music
		play(previousSong)

func play(songName:String) -> void:
	if curSong == songName: return;
	if fadeOutTween != null:
		if fadeOutTween.is_running(): fadeOutTween.stop();
	if fadeInTween != null:
		if fadeInTween.is_running(): fadeInTween.stop();
	if get_node_or_null(curSong) != null:
		fadeOutTween = get_tree().create_tween()
		fadeOutTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fadeOutTween.tween_property(get_node(curSong), "volume_db", -20, 1).set_trans(Tween.TRANS_SINE)
		fadeOutTween.tween_property(get_node(curSong), "playing", false, 0.1).set_trans(Tween.TRANS_SINE)
	curSong = songName
	if get_node_or_null(curSong) != null: 
		fadeInTween = get_tree().create_tween()
		fadeInTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fadeInTween.tween_property(get_node(curSong), "playing", true, 0.1).set_trans(Tween.TRANS_SINE)
		fadeInTween.tween_property(get_node(curSong), "volume_db", maxVolume, 1).set_trans(Tween.TRANS_SINE)

func changeVolume(newVolume:int) -> void:
	if newVolume == -20: newVolume = -80;
	maxVolume = newVolume
	if get_node_or_null(curSong) == null: return;
	get_node(curSong).volume_db = newVolume
