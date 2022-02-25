extends HBoxContainer

var highscore_name
var highscore_score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$name.text = highscore_name
	$score.text = String(highscore_score)
