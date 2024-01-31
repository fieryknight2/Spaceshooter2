extends Sprite2D

@export var move_speed : float
@export var max_scale : float
@export var min_scale : float

@export var max_yellow : float
@export var max_green : float
@export var base_color : Color

var ms
var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	rotation_degrees = rand.randi_range(0, 360)
	
	# set to a random speed
	scale.x = rand.randf_range(min_scale, max_scale)
	scale.y = scale.x
	# set speed so the smaller the scale the slower you go
	ms = rand.randf_range(move_speed, move_speed*move_speed*scale.x)
	
	var rand_yellow = base_color.lerp(Color(max_yellow, max_yellow, 0), rand.randf_range(0.0, 1.0))
	var rand_green = base_color.lerp(Color(0, max_green, 0), rand.randf_range(0.0, 1.0))
	modulate = rand_green.blend(rand_yellow)
	
	
	
func _process(delta):
	# move star down
	position.y += ms * delta * get_tree().current_scene.speed_scale
	
	# check if star is 50 units offscreen
	if position.y > get_viewport().size.y + 50:
		queue_free()
	 
