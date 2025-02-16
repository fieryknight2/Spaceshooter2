extends Area2D

# spaceship movement script
@export var move_speed : float
@export var action_speed : float
@export var max_velocity : float
@export var deceleration : float
@export var reload_time : float
@export var damage : int
@export var max_health : int
@export var health_reload : float
@export var score_modifier : float
@export var wall_boundaries : float
@export var wall_margin : float
@export var explosion : PackedScene
@export var projectile : PackedScene
@export var fire_points : Array[NodePath]
@export var max_energy : float
@export var energy_reload : float
@export var shot_energy : float

var velocity = Vector2()
var can_fire = true
var health
var th
var energy
var size_x = 0
var size_y = 0

var margin_effect = 0.15

signal player_death

func _ready():
	# set spaceship position
	position.x = get_viewport().size.x / 2
	position.y = get_viewport().size.y / 2 + get_viewport().size.y / 4
	
	$Health.max_value = max_health
	health = max_health
	th = health
	energy = max_energy
	
	# Find the size of the object (max x and max y of collision polygon)
	var poly = $CollisionPolygon2D.get_polygon()
	for point in poly:
		if point.x > size_x:
			size_x = point.x
		if point.y > size_y:
			size_y = point.y

func _process(delta):
	# get input movement
	var move = Vector2()
	# y direction is backwards, -y is equal to going up
	move.y = Input.get_action_strength("down") - Input.get_action_strength("up") # down (+) - up (-)
	move.x = Input.get_action_strength("right") - Input.get_action_strength("left") # right (+) - left (-)
	
	if Input.is_action_pressed("mouse_guide"):
		var pos = get_viewport().get_mouse_position()
		# use simple geometry to get direction towards mouse
		var dir_to = pos - position
		move = dir_to
	move = move.normalized() # make sure move always has a magnitude of 1
	
	# increment velocity by acceleration:
	var accel = delta * move * action_speed
	velocity += accel
	
	# implement some sort of deceleration
	velocity.x = lerpf(velocity.x, 0, deceleration * delta)
	velocity.y = lerpf(velocity.y, 0, deceleration * delta)
	
	velocity.x = clamp(velocity.x, -max_velocity, max_velocity) # keep x velocity within bounds
	velocity.y = clamp(velocity.y, -max_velocity, max_velocity) # keep y velocity within bounds
	
	# Prevent shaky spaceships
	#if velocity.x > -(delta * action_speed / 2) and velocity.x < (delta * action_speed / 2):
	#	velocity.x = 0
	#if velocity.y > -(delta * action_speed / 2) and velocity.y < (delta * action_speed / 2):
	#	velocity.y = 0
	
	# Code here is for automatic deceleration as we get close to the wall
	# (so it doesn't feel so solid)
	# wall margin is the distance from the boundaries to start deceleration
	# X: left side
	if position.x < (wall_boundaries + wall_margin) and velocity.x < 0:
		# delta * action_speed [* move] == acceleration
		# get total distance from wall: 
		var d_from_w = position.x - wall_boundaries
		# divide it by the distance between wall and margin  to get:
		var p_dis = d_from_w / wall_margin
		
		# decelerate depending how close you are to the wall
		# 1 - (accel.x * p_dis) should make the deceleration faster the smaller p_dis is
		# Decelerate by acceleration * dis_from_wall
		velocity.x += abs(velocity.x * margin_effect * (1 - p_dis))
		# Clamp ensures no shenanigans happen
		velocity.x = clamp(velocity.x, -max_velocity, 0)
	
	# X: right side 
	if position.x > (get_viewport().size.x - wall_boundaries - wall_margin) and velocity.x > 0:
		# Similar for this:
		# In this case we need to use the far end (viewport.size.x) and the far
		# side of our collision polygon (position.x + size.x)
		# get total distance from wall and then divide it by the distance between wall and margin:
		var d_from_w = abs((get_viewport().size.x - wall_boundaries) - (position.x + size_x))
		var p_dis = d_from_w / wall_margin
		
		# decelerate depending on how close to the wall you are
		velocity.x -= velocity.x * margin_effect * (1 - p_dis)
		velocity.x = clamp(velocity.x, 0, max_velocity)
	
	# Y: top side
	if position.y < (wall_boundaries + wall_margin) and velocity.y < 0:
		# Start with simple and then go complex: (See above for details)
		var d_from_w = position.y - wall_boundaries
		var p_dis = d_from_w / wall_margin
		
		# Decelerate based on how close we are to the wall 
		velocity.y += abs(velocity.y * margin_effect * (1 - p_dis))
		velocity.y = clamp(velocity.y, -max_velocity, 0)
	
	# Y: bottom_side
	if position.y > (get_viewport().size.y - wall_boundaries - wall_margin) and velocity.y > 0:
		# Now for the complex one again (See above for details)
		var d_from_w = abs(get_viewport().size.y - wall_boundaries) - (position.y + size_y)
		var p_dis = d_from_w / wall_margin
		
		# Decelerate based on how close we are to the wall
		velocity.y -= velocity.y * margin_effect * (1 - p_dis)
		velocity.y = clamp(velocity.y, 0, max_velocity)
	
	# move position by velocity
	position += velocity * move_speed * delta
	
	# Clamp position to boundaries
	# But we also need to make sure velocity is reset if we're outside the boundaries
	if (position.x < wall_boundaries and velocity.x < 0) or \
			(position.x > get_viewport().size.x - wall_boundaries and velocity.x > 0): 
		velocity.x = 0
	if (position.y < wall_boundaries and velocity.y < 0) or \
			(position.y > get_viewport().size.y - wall_boundaries and velocity.y > 0):
		velocity.y = 0
	
	position.x = clamp(position.x, wall_boundaries, 
									get_viewport().size.x - wall_boundaries)
	position.y = clamp(position.y, wall_boundaries,
									get_viewport().size.y - wall_boundaries)
	
	# fire bullets
	if Input.is_action_pressed("fire") and can_fire:
		can_fire = false
		if energy > shot_energy:
			$Reload.start(reload_time / get_tree().current_scene.speed_scale)
		
		fire_points.shuffle(); # Randomly fire from different points when low on energy
		for p in fire_points:
			if energy < shot_energy:
				continue
			var e = projectile.instantiate()
			e.position = get_node(p).position + position
			e.rotation = get_node(p).rotation
			e.damage = damage
			energy -= shot_energy
			get_tree().current_scene.add_child(e)
	
	if th > health:
		Input.start_joy_vibration(0, 1, 0.1, 0.1)
		th = health
		
	$Health.value = health
	
	# check if the spaceship is still alive
	if (health <= 0):
		die()
	else:
		if energy > health_reload * delta:
			if health < max_health:
				energy -= health_reload * delta * get_tree().current_scene.speed_scale
				health += health_reload * delta * get_tree().current_scene.speed_scale
				$Health.show()
			else:
				$Health.hide()
		health = clamp(health, 0, max_health)
	
	if energy < max_energy:
		energy += energy_reload * delta * get_tree().current_scene.speed_scale
		energy = clamp(energy, 0, max_energy)

func die():
	emit_signal("player_death")
	
	Input.start_joy_vibration(0, 1, 1, 1) # play haptics
	
	# boom
	var e = explosion.instantiate()
	e.scale = scale
	e.position = position
	e.volume = -10
	get_tree().current_scene.add_child(e)
	
	queue_free()

func _on_Spaceship_area_entered(area):
	if area.is_in_group("asteroids"):
		var h = area.health
		area.die()
		health -= h
	if area.is_in_group("enemies"):
		var h = area.health
		if health > h:
			area.die()
			health -= h
		else:
			area.health -= h
			die()
			


func _on_Reload_timeout():
	can_fire = true
