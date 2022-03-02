extends Area2D

export (float) var movement_speed
export (float) var turn_speed
export (int) var border
export (int) var health
export (float) var reload_time
export (int) var damage
export (PackedScene) var explosion
export (PackedScene) var projectile
export (Array, NodePath) var fire_points

var max_health
var t_dir = 0

var rg = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rg.randomize()
	$Fire.start(reload_time)
	max_health = health
	$Health.max_value = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health >= max_health:
		$Health.visible = false
	else:
		$Health.visible = true
		
	$Sprite.rotation_degrees += t_dir * delta * turn_speed * get_tree().current_scene.speed_scale
	if $Sprite.rotation_degrees < 70:
		t_dir = 1
	if $Sprite.rotation_degrees > 110:
		t_dir = -1
	$Sprite.rotation_degrees = clamp($Sprite.rotation_degrees, 70, 110)
	
	var velo = Vector2(movement_speed * get_tree().current_scene.speed_scale, 0).rotated($Sprite.rotation)
	position += velo * delta
	
	if position.y > get_viewport().size.y + 100:
		queue_free()
		
	if position.x <= border:
		t_dir = -1
	if position.x >= get_viewport().size.x - border:
		t_dir = 1
	position.x = clamp(position.x, border, get_viewport().size.x - border)
	
	if health <= 0:
		die()
		return
	$Health.value = health
	
func die():
	# boom
	var e = explosion.instance()
	e.position = position
	get_tree().current_scene.add_child(e)
	
	get_tree().current_scene.score += 250 * get_tree().current_scene.speed_scale * get_tree().current_scene.score_mod
	
	queue_free()
	
func deal_damage(damage):
	health -= damage

func _on_Fire_timeout():
	$Fire.start(reload_time / get_tree().current_scene.speed_scale)
	
	if position.y < 0:
		return
		
	for f in fire_points:
		var p = projectile.instance()
		p.position = get_node(f).global_position
		p.rotation = get_node(f).global_rotation
		p.damage = damage
		
		get_tree().current_scene.add_child(p)
