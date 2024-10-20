extends Node2D

signal downloadedSingularity
signal downloadedFree
signal enableWifi

@onready var animationPlayers:Array[AnimationPlayer] = [
	$internetAnims,
	$homepage/homepageAnims,
	$newsResults/newsAnims,
	$newsResults/article1/hoverAnims,
	$newsResults/article2/hoverAnims,
	$weatherResults/weatherAnims,
	$weatherResults/article1/hoverAnims,
	$gameResults/gameAnims,
	$gameResults/article1/description/descriptionAnim,
	$gameResults/article1/hoverAnims,
	$gameResults/article2/hoverAnims,
	$gameResults/article3/hoverAnims,
	$imageResults/imageAnims
]

func _process(delta: float) -> void:
	if (!$gameResults/article2Open.visible or !visible) and $gameResults/article2Open/slimyBirdGame.alive:
		$gameResults/article2Open/slimyBirdGame.stop()

func increaseProgressCount(time:float):
	var pauseTime:float = time / 101.0
	for num in range(101):
		%progressCount.text = str(num) + "%"
		await get_tree().create_timer(pauseTime).timeout

func increaseFreeProgressCount(time:float):
	var pauseTime:float = time / 101.0
	for num in range(101):
		%freeProgressCount.text = str(num) + "%"
		await get_tree().create_timer(pauseTime).timeout

func installSingularity(): emit_signal("downloadedSingularity");
func installFree(): emit_signal("downloadedFree");

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
