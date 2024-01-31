extends Node2D

# simple movement script

@export var speed_value : float
@export var rotate_speed : float
@export var fade_speed : float
var speed = 0 
var rotate_dir = 0
var move_dir = Vector2()

var r = RandomNumberGenerator.new()

func _ready():
	r.randomize()
	# randomize rotation and visiblity
	rotate_dir = r.randf_range(-1, 1)
	z_index = r.randi_range(-20, 20)
	
	scale.x = r.randf_range(0.6, 2)
	scale.y = scale.x
	
	move_dir = Vector2(r.randf_range(-1, 1), r.randf_range(-1, 1))
	move_dir = move_dir.normalized()

func _process(delta):
	# move in move direction, rotate, and slowly disappear
	position += move_dir * speed * speed_value * delta
	rotation_degrees += delta * rotate_dir * rotate_speed
	modulate.a -= delta * fade_speed
	
	# if chunk is out of sight or completely hidden, then delete the chunk
	if position.y > get_viewport().size.y + 50 or modulate.a <= 0:
		queue_free()
