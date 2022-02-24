extends Area2D

export (float) var movement_speed
export (float) var slow_speed
export (float) var vel_length
export (float) var downward_speed
export (int) var border
export (int) var health
export (float) var reload_time
export (int) var damage
export (PackedScene) var explosion
export (PackedScene) var projectile
export (Array, NodePath) var fire_points

var max_health
var direction = 0

func _ready():
	$Fire.start(reload_time)
	max_health = health
	$Health.max_value = max_health

func _process(delta):
	if direction == 0:
		direction = rand_range(-vel_length, vel_length)
	else:
		if direction > 0:
			direction -= slow_speed * delta
			if direction < 0:
				direction = 0
		if direction < 0:
			direction += slow_speed * delta
			if direction > 0:
				direction = 0
	
	if direction > 0:
		position.x += movement_speed * delta  * get_tree().current_scene.speed_scale
	elif direction < 0:
		position.x -= movement_speed * delta * get_tree().current_scene.speed_scale
	if (position.x <= border and direction < 0) or \
	   (position.x >= get_viewport().size.x - border and direction > 0):
		direction = -direction
	position.x = clamp(position.x, border, get_viewport().size.x - border)
	position.y += downward_speed * delta * get_tree().current_scene.speed_scale
	
	if position.y > get_viewport().size.y + 100:
		queue_free()
		
	if health <= 0:
		die()
	else:
		if health != max_health:
			$Health.show()
			$Health.value = health
		else:
			$Health.hide()

func die():
	# boom
	var e = explosion.instance()
	e.position = position
	get_tree().current_scene.add_child(e)
	
	get_tree().current_scene.score += 500 * get_tree().current_scene.speed_scale
	
	queue_free()

func _on_Fire_timeout():
	$Fire.start(reload_time)
	
	if position.y < 0:
		return
		
	for e in fire_points:
		var fp = projectile.instance()
		fp.position = get_node(e).position + position
		fp.damage = damage
		get_tree().current_scene.add_child(fp)
