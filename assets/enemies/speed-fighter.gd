extends Area2D

@export var movement_speed : float
@export var turn_speed : float
@export var border : int
@export var health : int
@export var reload_time : float
@export var damage : int
@export var explosion : PackedScene
@export var projectile : PackedScene
@export var fire_points : Array[NodePath]

var max_health
var t_dir = 0

var rg = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	health = clamp(health * get_tree().current_scene.health_speed_up, health, health*50)
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
		
	$Sprite2D.rotation_degrees += t_dir * delta * turn_speed * get_tree().current_scene.speed_scale
	if $Sprite2D.rotation_degrees < 70:
		t_dir = 1
	if $Sprite2D.rotation_degrees > 110:
		t_dir = -1
	$Sprite2D.rotation_degrees = clamp($Sprite2D.rotation_degrees, 70, 110)
	
	var velo = Vector2(movement_speed * get_tree().current_scene.speed_scale, 0).rotated($Sprite2D.rotation)
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
	var e = explosion.instantiate()
	e.position = position
	e.volume = -22
	get_tree().current_scene.add_child(e)
	
	get_tree().current_scene.score += 250 * get_tree().current_scene.speed_scale * get_tree().current_scene.score_mod
	
	queue_free()
	
func deal_damage(dmg):
	health -= dmg

func _on_Fire_timeout():
	$Fire.start(reload_time / get_tree().current_scene.speed_scale)
	
	if position.y < 0:
		return
		
	for f in fire_points:
		var p = projectile.instantiate()
		p.position = get_node(f).global_position
		p.rotation = get_node(f).global_rotation
		p.damage = damage
		
		get_tree().current_scene.add_child(p)
