extends Node2D

@export var enemy : PackedScene
@export var enemy2 : PackedScene
@export var boss1 : PackedScene
@export var boss1_time : int
@export var increase_score_by : int

var prev1_score = 0
func _ready():
	$E1.start(15 / get_tree().current_scene.speed_scale)
	$E2.start(randf_range(35, 50) / get_tree().current_scene.speed_scale)
	$Boss.start(randf_range(boss1_time - 15, boss1_time + 15) / get_tree().current_scene.speed_scale)

func _process(_delta):
	if $Boss.time_left < 5:
		$E1.stop()
		$E2.stop()
		
func _on_Timer_timeout():
	var e = enemy.instantiate()
	
	e.position.x = randf_range(0, get_viewport().size.x)
	e.position.y = -100
	
	get_tree().current_scene.call_deferred("add_child", e)
	$E1.start(randf_range(60, 100) / get_tree().current_scene.speed_scale)


func _on_E2_timeout():
	var e = enemy2.instantiate()
	
	e.position.x = randf_range(0, get_viewport().size.x)
	e.position.y = -100
	e.t_dir = randf_range(-1, 1)
	
	get_tree().current_scene.call_deferred("add_child", e)
	$E2.start(randf_range(35, 50) / get_tree().current_scene.speed_scale)


func _on_Boss_timeout():
	var e = boss1.instantiate()
	
	e.position.x = get_viewport().size.x / 2
	e.position.y = -100
	
	get_tree().current_scene.add_child(e)
	$Boss.start(randf_range(boss1_time - 15, boss1_time + 15) / get_tree().current_scene.speed_scale)
