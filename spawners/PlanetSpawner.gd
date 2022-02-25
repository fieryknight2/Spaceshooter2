extends Node2D

# simple planet spawner (for background)

export (Array, PackedScene) var planets

var rg = RandomNumberGenerator.new()

func _ready():
	rg.randomize()
	
	# spawn initial planet
	spawn_planet()
	
func spawn_planet():
	# create planet instance
	var p = planets[rg.randi_range(0, planets.size() - 1)].instance()
	
	# set planet position
	p.position.x = rg.randf_range(-5, get_viewport().size.x + 5)
	p.position.y = -300
	
	# set planet rotation speed and movement speed
	p.rotate_speed = rg.randf_range(-3, 3)
	p.move_speed = rg.randf_range(3, 15)
	
	# add as child
	add_child(p)
	
	$Timer.wait_time = rg.randf_range(90, 180) / get_tree().current_scene.speed_scale
	$Timer.start()

func _on_Timer_timeout():
	spawn_planet()
