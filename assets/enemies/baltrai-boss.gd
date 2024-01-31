extends Area2D

@export var turrets : Array[NodePath]
@export var l1lasers : Array[NodePath]
@export var l5lasers_1 : Array[NodePath]
@export var l5lasers_2 : Array[NodePath]
@export var l10lasers : Array[NodePath]
@export var explosion : PackedScene
@export var giant_laser : PackedScene
@export var big_laser : PackedScene
@export var little_laser : PackedScene
@export var turret_wait : float
@export var l1laser_wait : float
@export var l5laser_wait : float
@export var l10laser_wait : float

@export var move_speed : float
@export var health : int

var max_health
var c_turret = 0
var c_slaser = 0
var c_mlaser = false

# Called when the node enters the scene tree for the first time.
func _ready():
	health = clamp(health * get_tree().current_scene.health_speed_up, health, health*50)
	$T.start(turret_wait)
	$L1.start(l1laser_wait)
	$L5.start(l5laser_wait)
	$L10.start(l10laser_wait)
	
	max_health = health
	
	get_tree().current_scene.start_boss(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += move_speed * delta * get_tree().current_scene.speed_scale
	if position.y > get_viewport().size.x + 192: # this is pointless, but whatever...
		queue_free()
			
	if health <= 0:
		die()

func deal_damage(damage):
	health -= damage
	
func die():
	get_tree().current_scene.end_boss()
	
	var e = explosion.instantiate()
	e.position = position
	e.scale.x = 2
	e.scale.y = 2
	e.volume = -10
	get_tree().current_scene.add_child(e)
	
	get_tree().current_scene.score += 5000 * get_tree().current_scene.speed_scale * \
									 get_tree().current_scene.score_mod
	
	# test this line:s
	get_tree().current_scene.speed_scale += 0.05
	
	queue_free()

func _on_T_timeout():
	$T.start(turret_wait * get_tree().current_scene.speed_scale)
	
	if c_turret >= len(turrets):
		c_turret = 0
	
	var t = little_laser.instantiate()
	t.damage = 1
	t.position = get_node(turrets[c_turret]).fp.global_position
	t.rotation = get_node(turrets[c_turret]).fp.global_rotation
	t.rotation_degrees -= 90
	get_tree().current_scene.add_child(t)
	
	c_turret += 1


func _on_L1_timeout():
	$L1.start(l1laser_wait * get_tree().current_scene.speed_scale)
	
	if c_slaser >= len(l1lasers):
		c_slaser = 0
		
	var l = little_laser.instantiate()
	l.position = get_node(l1lasers[c_slaser]).global_position
	l.rotation = get_node(l1lasers[c_slaser]).global_rotation
	l.damage = 1
	get_tree().current_scene.add_child(l)
	
	c_slaser += 1


func _on_L5_timeout():
	$L5.start(l5laser_wait * get_tree().current_scene.speed_scale)
	
	var x
	if c_mlaser:
		x = l5lasers_1
	else:
		x = l5lasers_2
	c_mlaser = not c_mlaser
	
	for laser in x:
		var l = big_laser.instantiate()
		l.position = get_node(laser).global_position
		l.rotation = get_node(laser).global_rotation
		l.damage = 5
		get_tree().current_scene.add_child(l)


func _on_L10_timeout():
	$L10.start(l10laser_wait * get_tree().current_scene.speed_scale)
	
	for laser in l10lasers:
		var l = giant_laser.instantiate()
		l.position = get_node(laser).global_position
		l.rotation = get_node(laser).global_rotation
		l.damage = 10
		get_tree().current_scene.add_child(l)
