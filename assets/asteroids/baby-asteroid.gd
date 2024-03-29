extends Area2D

@export var asteroids : Array[PackedScene]
@export var asteroid_chunk : PackedScene
@export var explosion : PackedScene
var speed
var size
var health : float
var mhealth : float
var rspeed

var rg = RandomNumberGenerator.new()

func _ready():
	rg.randomize()
	
	# set a random image for this asteroid
	var image = rg.randi_range(0, asteroids.size() - 1)
	$cracks.add_sibling(asteroids[image].instantiate())
	
	# all we need to do here is set the size
	scale.x = size * 0.2
	scale.y = size * 0.2
	
	mhealth = health

func _process(delta):
	# move the asteroid down
	position.y += speed * delta * get_tree().current_scene.speed_scale
	# rotate the asteroid
	$Collider.rotation_degrees += rspeed * delta
	$cracks.rotation = $Collider.rotation
	
	if health <= 0:
		die()
	$cracks.frame = clamp(int(health/mhealth * 5), 0, 5)

func die():
	# boom
	var e = explosion.instantiate()
	e.scale = scale / 2
	e.position = position
	e.volume = -22
	get_tree().current_scene.add_child(e)
	
	# create 2 asteroid chunks
	for _i in range(2):
		var ac = asteroid_chunk.instantiate()
		# move to a random location near the asteroid
		ac.position = Vector2(rg.randf_range(position.x-2, position.x+2), 
							  rg.randf_range(position.y-2, position.y+2))
		# chunk should fall quickly into the background
		ac.speed = speed * 2
		# add asteroid to scene
		get_tree().current_scene.add_child(ac)
	
	get_tree().current_scene.score += int(scale.x * 10) * get_tree().current_scene.speed_scale * get_tree().current_scene.score_mod
	queue_free()

func deal_damage(damage):
	health -= damage
