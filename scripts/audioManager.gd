extends Node3D

var curSong:String = "none"

func play(songName:String):
	if get_node_or_null(curSong) != null:
		var fadeOutTween = get_tree().create_tween()
		fadeOutTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fadeOutTween.tween_property(get_node(curSong), "volume_db", -20, 1).set_trans(Tween.TRANS_SINE)
		fadeOutTween.tween_property(get_node(curSong), "playing", false, 0.1).set_trans(Tween.TRANS_SINE)
	curSong = songName
	if get_node_or_null(curSong) != null: 
		var fadeInTween = get_tree().create_tween()
		fadeInTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		fadeInTween.tween_property(get_node(curSong), "playing", true, 0.1).set_trans(Tween.TRANS_SINE)
		fadeInTween.tween_property(get_node(curSong), "volume_db", 0, 1).set_trans(Tween.TRANS_SINE)
