extends Area2D

export (Array, Texture) var asteroids
export (float) var max_speed
export (float) var min_speed
export (float) var max_size
export (float) var min_size
export (float) var rotate_speed
export (int) var health_value

export (PackedScene) var baby_asteroid
export (PackedScene) var asteroid_chunk
export (PackedScene) var explosion

var rg = RandomNumberGenerator.new()

var speed
var size
var health
var mhealth
var rspeed

func _ready():
	rg.randomize()
	
	# set a random image for this asteroid
	var image = rg.randi_range(0, asteroids.size() - 1)
	var sprite = get_child(0)
	sprite.texture = asteroids[image]
	
	# random speed
	speed = rg.randf_range(min_speed, max_speed)
	# random size
	size = rg.randf_range(min_size, max_size)
	scale.x = size
	scale.y = size
	
	# health is less the faster the asteroid goes, and more the larger the asteroid is
	health = health_value * size/max_size * speed/max_speed
	mhealth = health
	
	# random rotation speed
	rspeed = rg.randf_range(-rotate_speed, rotate_speed)

func _process(delta):
	if health <= 0:
		die()
		return
	$cracks.frame = int(health/mhealth * 5)
		
		
	# check if the asteroid is 100 units offscreen
	if position.y > get_viewport().size.y + 100:
		queue_free()
		return
		
	# move the asteroid:
	position.y += speed * delta * get_tree().current_scene.speed_scale
	# rotate the asteroid:
	rotation_degrees += rspeed * delta
	
func die():
	# boom
	var e = explosion.instance()
	e.scale = scale
	e.position = position
	get_tree().current_scene.add_child(e)
	
	# player gets points here
	
	# size/max_size = 0.size_value(extra)
	# 0.size_value(extra) * 10 = size_value.(extra)
	# int(size_value.(extra) = size_value
	var size_value = int(size/max_size * 10)
	if (size_value > 7):
		# if size value is more than 0.7, create new tiny asteroids
		for _i in range(size_value - 7):
			var ba = baby_asteroid.instance()
			# move to a random location near the asteroid
			ba.position = Vector2(rg.randf_range(position.x-60, position.x+60), 
								  rg.randf_range(position.y-60, position.y+60))
			# bigger the asteroid, bigger the size
			ba.size = size_value - 7
			ba.speed = speed * 1.5
			# set the baby health, this is subject to tweaking
			ba.health =  health_value / 4
			# add asteroid to scene
			get_tree().current_scene.call_deferred("add_child", ba)
	# create extra asteroid chunks (1 chunk for every 2 size values)
	for _i in range(int(size_value / 2)):
		var ac = asteroid_chunk.instance()
		# move to a random location near the asteroid
		ac.position = Vector2(rg.randf_range(position.x-20, position.x+20), 
							  rg.randf_range(position.y-20, position.y+20))
		# chunk should fall quickly into the background
		ac.speed = speed * 2
		# add asteroid to scene
		get_tree().current_scene.add_child(ac)
	
	get_tree().current_scene.score += 10 * size_value * get_tree().current_scene.speed_scale * get_tree().current_scene.score_mod
	queue_free()

func deal_damage(damage):
	health -= damage
