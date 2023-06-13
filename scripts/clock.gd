extends MeshInstance3D
# Clock morse code
var text:String = "--- -. -.-. . --..-- / - .... . .-. . / .-.. .. ...- . -.. / .- / -... . .. -. --
. / --- ..-. / ..- -. .. -- .- --. .. -. .- -... .-.. . / .--. --- .-- . .-. .-.-.- / -... --- .-. -
. / --- ..-. / .- / -.. . ... .. .-. . / - --- / -.- -. --- .-- / .- .-.. .-.. --..-- / .. - / .--- 
--- ..- .-. -. . -.-- . -.. / - .... .-. --- ..- --. .... --- ..- - / - .... . / . - .... . .-. --..
-- / .. -. / ... . .- .-. -.-. .... / --- ..-. / - .... . / - .-. ..- - .... .-.-.- / - .... .-. ---
 ..- --. .... / ..-. --- .-. . ... - ... / ..- -. - --- ..- -.-. .... . -.. / -... -.-- / -- .- -. -
-..-- / -.-. .. ...- .. .-.. .. --.. .- - .. --- -. ... / --- -. -.-. . / ..-. --- .-. --. --- - - .
 -. --..-- / .- -. -.. / .--. .-.. .- -. . - ... / - .... .- - / -.. . ..-. .. . -.. / .-. . .- .-..
 .. - -.-- .-.-.- / ..- -. - .. .-.. / --- -. . / -.. .- -.-- --..-- / .. - / -.-. .- -- . / .- -.-.
 .-. --- ... ... / ... --- -- . - .... .. -. --. / .. -- .--. --- ... ... .. -... .-.. . .-.-.- / - 
.-. -.-- / .- ... / .. - / -- .. --. .... - --..-- / .. - / -.-. --- ..- .-.. -.. / -. --- - / -.-. 
--- -- .--. .-. . .... . -. -.. / .. - ... / . -..- .. ... - . -. -.-. . .-.-.- / .- -. -.. / ... --
- / .. - / -... . --. .- -. / - --- / -.-. .-. . .- - . / .-- --- .-. .-.. -.. ... / --- ..-. / .. -
 ... / --- .-- -. --..-- / - --- / ..-. .. -. -.. / -... . .. -. --. ... / ... .. -- .. .-.. .- .-. 
/ - --- / .. - ... . .-.. ..-. --..-- / .. -. / - .... . / .... --- .--. . ... / - .... .- - / - ...
. . -.-- / -.-. --- ..- .-.. -.. / ..- -. -.. . .-. ... - .- -. -.. / .-- .... .- - / .. - / -.-. --
- ..- .-.. -.. / -. --- - .-.-.-"
var textArr:Array[String] = [] # Morse code in array form
# Creates initial morse code array
func _ready() -> void: recompileText();
# Converts morse code to array
func recompileText() -> void:
	for char in text: textArr.append(char);
# Plays next morse code letter
func _on_clock_timer_timeout() -> void:
	var char:String = textArr.pop_front() # Get next letter
	$clockTimer.wait_time = 1.0 # Default pause time
	match char:
		"-": $clockAnims.play("wiggleHour"); # Long pulse
		".": $clockAnims.play("wiggleMinute");# Short pulse
		" ": $clockTimer.wait_time = 2.0;# End of letter
		"/": $clockTimer.wait_time = 3.0;# End of word
	
	if len(textArr) == 0: # Repeats morse code once message complete
		recompileText()
		$clockTimer.wait_time = 5.0
	
