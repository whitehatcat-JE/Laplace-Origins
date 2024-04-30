extends Node2D

signal downloadedSingularity

func increaseProgressCount(time:float):
	var pauseTime:float = time / 101.0
	for num in range(101):
		%progressCount.text = str(num) + "%"
		await get_tree().create_timer(pauseTime).timeout

func installSingularity():
	emit_signal("downloadedSingularity")
