extends Node2D

# simple spawner script for spawning asteroids

export (PackedScene) var asteroid

var rg = RandomNumberGenerator.new()

func _ready():
	rg.randomize()
	
	# add initial asteroid
	_on_Timer_timeout()

func _on_Timer_timeout():
	# create asteroid instance
	var a = asteroid.instance()
	
	# set asteroid position
	a.position.x = rg.randf_range(0, get_viewport().size.x)
	a.position.y = -75
	
	# add asteroid to scene
	get_tree().current_scene.call_deferred("add_child", a)
	$Timer.wait_time = 3 / get_tree().current_scene.speed_scale
