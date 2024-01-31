extends Area2D

@export var movement_speed : float
@export var slow_speed : float
@export var vel_length : float
@export var downward_speed : float
@export var border : int
@export var health : int
@export var reload_time : float
@export var damage : int
@export var explosion : PackedScene
@export var projectile : PackedScene
@export var fire_points : Array[NodePath]

var max_health
var direction = 0

func _ready():
	health = clamp(health * get_tree().current_scene.health_speed_up, health, health*50)
	$Fire.start(reload_time)
	max_health = health
	$Health.max_value = max_health

func _process(delta):
	if direction == 0:
		direction = randf_range(-vel_length, vel_length)
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
	var e = explosion.instantiate()
	e.position = position
	e.volume = -20
	get_tree().current_scene.add_child(e)
	
	get_tree().current_scene.score += 500 * get_tree().current_scene.speed_scale * get_tree().current_scene.score_mod
	
	queue_free()

func _on_Fire_timeout():
	$Fire.start(reload_time / get_tree().current_scene.speed_scale)
	
	if position.y < 0:
		return
		
	for e in fire_points:
		var fp = projectile.instantiate()
		fp.position = get_node(e).position + position
		fp.damage = damage
		get_tree().current_scene.add_child(fp)
