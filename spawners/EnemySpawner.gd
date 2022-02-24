extends Node2D

export (PackedScene) var enemy

func _ready():
	$Timer.start(15 / get_tree().current_scene.speed_scale)

func _on_Timer_timeout():
	var e = enemy.instance()
	
	e.position.x = rand_range(0, get_viewport().size.x)
	e.position.y = -100
	
	get_tree().current_scene.call_deferred("add_child", e)
	$Timer.start(60 / get_tree().current_scene.speed_scale)
	
