extends HBoxContainer

var highscore_ship
var highscore_score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$ship.text = highscore_ship
	$score.text = String(highscore_score)
