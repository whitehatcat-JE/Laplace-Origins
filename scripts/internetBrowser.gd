extends Node2D
# Internet Status Signals (For communication with pcOS)
signal downloadedSingularity
signal downloadedFree
signal enableWifi
# Checks if slimybird minigame is in focus
func _process(delta: float) -> void:
	if (!$gameResults/article2Open.visible or !visible) and $gameResults/article2Open/slimyBirdGame.alive:
		$gameResults/article2Open/slimyBirdGame.stop()
# Increase download count for singularity minigame
func increaseProgressCount(time:float):
	var pauseTime:float = time / 101.0
	for num in range(101):
		%progressCount.text = str(num) + "%"
		await get_tree().create_timer(pauseTime).timeout
# Increase download count for virus
func increaseFreeProgressCount(time:float):
	var pauseTime:float = time / 101.0
	for num in range(101):
		%freeProgressCount.text = str(num) + "%"
		await get_tree().create_timer(pauseTime).timeout
# Show downloaded minigames in filesystem
func installSingularity(): emit_signal("downloadedSingularity");
func installFree(): emit_signal("downloadedFree");
# Disable internet browser and return to homepage
func disableInternet():
	$weatherResults/weatherAnims.play("hideWeather")
	$weatherResults/weatherAnims.advance(2.0)
	$newsResults/newsAnims.play("hideNews")
	$newsResults/newsAnims.advance(2.0)
	$gameResults/gameAnims.play("hideGames")
	$gameResults/gameAnims.advance(2.0)
	$homepage/homepageAnims.play("hideResults")
	$homepage/homepageAnims.advance(1.0)
	$homepage.position.x = 10000.0
	$offlineMessage.visible = true
	$windowName.text = "Internet - Offline"
# Enable internet browser and switch to weeping variant
func enableInternet():
	$weatherResults/weatherAnims.play("hideWeather")
	$weatherResults/weatherAnims.advance(2.0)
	$newsResults/newsAnims.play("hideNews")
	$newsResults/newsAnims.advance(2.0)
	$gameResults/gameAnims.play("hideGames")
	$gameResults/gameAnims.advance(2.0)
	$homepage/homepageAnims.play("hideResults")
	$homepage/homepageAnims.advance(1.0)
	$homepage.position.x = 0.0
	$offlineMessage.visible = false
	emit_signal("enableWifi")
	$internetAnims.play("weep")
