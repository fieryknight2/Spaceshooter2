extends Node2D

export (PackedScene) var enemy
export (PackedScene) var enemy2

func _ready():
	$E1.start(15 / get_tree().current_scene.speed_scale)
	$E2.start(rand_range(35, 50) / get_tree().current_scene.speed_scale)

func _on_Timer_timeout():
	var e = enemy.instance()
	
	e.position.x = rand_range(0, get_viewport().size.x)
	e.position.y = -100
	
	get_tree().current_scene.call_deferred("add_child", e)
	$E1.start(rand_range(60, 100) / get_tree().current_scene.speed_scale)


func _on_E2_timeout():
	var e = enemy2.instance()
	
	e.position.x = rand_range(0, get_viewport().size.x)
	e.position.y = -100
	e.t_dir = rand_range(-1, 1)
	
	get_tree().current_scene.call_deferred("add_child", e)
	$E2.start(rand_range(35, 50) / get_tree().current_scene.speed_scale)
