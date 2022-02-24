extends Sprite

export (float) var move_speed
export (float) var max_scale
export (float) var min_scale

var ms

func _ready():
	# set to a random speed
	scale.x = rand_range(min_scale, max_scale)
	scale.y = scale.x
	# set speed so the smaller the scale the slower you go
	ms = rand_range(move_speed, move_speed*move_speed*scale.x)
	
func _process(delta):
	# move star down
	position.y += ms * delta * get_tree().current_scene.speed_scale
	
	# check if star is 50 units offscreen
	if position.y > get_viewport().size.y + 50:
		queue_free()
	 
