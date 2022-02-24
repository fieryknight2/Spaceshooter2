extends Node2D

var score = 0
export (float) var speed_up
var speed_scale = 1

func _process(delta):
	score = int(score)
	$UI/Score.text = String(score)
	
	speed_scale += delta * speed_up
