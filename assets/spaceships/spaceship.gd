extends Area2D

# spaceship movement script
export (float) var move_speed
export (float) var action_speed
export (float) var max_velocity
export (float) var deceleration
export (float) var reload_time
export (int) var damage
export (int) var max_health
export (float) var health_reload
export (float) var wall_boundaries
export (PackedScene) var explosion
export (PackedScene) var projectile
export (Array, NodePath) var fire_points

var velocity = Vector2()
var can_fire = true
var health
var th

func _ready():
	# set spaceship position
	position.x = get_viewport().size.x / 2
	position.y = get_viewport().size.y / 2 + get_viewport().size.y / 4
	
	$Health.max_value = max_health
	health = max_health
	th = health

func _process(delta):
	# get input movement
	var move = Vector2()
	move.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if Input.is_action_pressed("mouse_guide"):
		var pos = get_viewport().get_mouse_position()
		var dir_to = pos - position
		move = dir_to.normalized()
	
	# increment velocity
	velocity += delta * move * action_speed
	velocity.x = clamp(velocity.x, -max_velocity, max_velocity)
	velocity.y = clamp(velocity.y, -max_velocity, max_velocity)
	
	if move.x == 0:
		if velocity.x > 0:
			velocity.x -= deceleration * delta
			velocity.x = clamp(velocity.x, 0, max_velocity)
		if velocity.x < 0:
			velocity.x += deceleration * delta
			velocity.x = clamp(velocity.x, -max_velocity, 0)
	if move.y == 0:
		if velocity.y > 0:
			velocity.y -= deceleration * delta
			velocity.y = clamp(velocity.y, 0, max_velocity)
		if velocity.y < 0:
			velocity.y += deceleration * delta
			velocity.y = clamp(velocity.y, -max_velocity, 0)
	
	# make sure we aren't trying to hit a wall
	# X: left side
	if position.x < wall_boundaries*2 and velocity.x < 0:
		velocity.x += deceleration * delta
		velocity.x = clamp(velocity.x, -max_velocity, 0)
	
	# X: right side
	if position.x > get_viewport().size.x - wall_boundaries*2 and velocity.x > 0:
		velocity.x -= deceleration * delta
		velocity.x = clamp(velocity.x, 0, max_velocity)
	
	# Y: bottom side
	if position.y > get_viewport().size.y - wall_boundaries*2 and velocity.y > 0:
		velocity.y -= deceleration * delta
		velocity.y = clamp(velocity.y, 0, max_velocity)
	
	# Y: top_side
	if position.y < get_viewport().size.y / 2 + wall_boundaries*2 and velocity.y < 0:
		velocity.y += deceleration * delta
		velocity.y = clamp(velocity.y, -max_velocity, 0)
	
	# move position by velocity
	position += velocity * move_speed * delta
	
	# clamp position to boundaries
	position.x = clamp(position.x, wall_boundaries, 
									get_viewport().size.x - wall_boundaries)
	position.y = clamp(position.y, get_viewport().size.y / 2 + wall_boundaries,
									get_viewport().size.y - wall_boundaries)
	
	# fire bullets
	if Input.is_action_pressed("fire") and can_fire:
		can_fire = false
		$Reload.start(reload_time / get_tree().current_scene.speed_scale)
		
		for p in fire_points:
			var e = projectile.instance()
			e.position = get_node(p).position + position
			e.rotation = get_node(p).rotation
			e.damage = damage
			get_tree().current_scene.add_child(e)
	
	if th > health:
		Input.start_joy_vibration(0, 1, 0.1, 0.1)
		th = health
		
	# check if the spaceship is still alive
	if (health <= 0):
		die()
	else:
		health = clamp(health, 0, max_health)
		if health != max_health:
			health += health_reload * delta
			$Health.value = health
			$Health.show()
		else:
			$Health.hide()

func die():
	Input.start_joy_vibration(0, 1, 1, 1)
	# boom
	var e = explosion.instance()
	e.scale = scale
	e.position = position
	get_tree().current_scene.add_child(e)
	get_tree().current_scene.player_die()
	
	queue_free()

func _on_Spaceship_area_entered(area):
	if area.is_in_group("asteroids"):
		var h = area.health
		area.die()
		health -= h
	if area.is_in_group("enemies"):
		var h = area.health
		area.die()
		health -= h


func _on_Reload_timeout():
	can_fire = true
