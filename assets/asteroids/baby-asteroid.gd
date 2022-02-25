extends Area2D


export (Array, Texture) var asteroids
export (PackedScene) var asteroid_chunk
export (PackedScene) var explosion
var speed
var size
var health : float
var mhealth : float

var rg = RandomNumberGenerator.new()

func _ready():
	rg.randomize()
	
	# all we need to do here is set the size
	# note that all the variables are set by the parent asteroid
	scale.x = size * 0.5
	scale.y = size * 0.5
	
	# set a random image for this asteroid
	var image = rg.randi_range(0, asteroids.size() - 1)
	var sprite = get_child(0)
	sprite.texture = asteroids[image]
	
	mhealth = health

func _process(delta):
	# move the asteroid down
	position.y += speed * delta * get_tree().current_scene.speed_scale
	
	if health <= 0:
		die()
	$cracks.frame = clamp(int(health/mhealth * 5), 0, 5)

func die():
	# boom
	var e = explosion.instance()
	e.scale = scale / 2
	e.position = position
	get_tree().current_scene.add_child(e)
	
	# player gets points here
	
	# create 2 asteroid chunks
	for _i in range(2):
		var ac = asteroid_chunk.instance()
		# move to a random location near the asteroid
		ac.position = Vector2(rg.randf_range(position.x-2, position.x+2), 
							  rg.randf_range(position.y-2, position.y+2))
		# chunk should fall quickly into the background
		ac.speed = speed * 2
		# add asteroid to scene
		get_tree().current_scene.add_child(ac)
	
	get_tree().current_scene.score += int(scale.x * 10) * get_tree().current_scene.speed_scale
	queue_free()

func deal_damage(damage):
	health -= damage
