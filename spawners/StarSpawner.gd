extends Node2D

# simple spawner script for spawning stars

export (PackedScene) var star

func _ready():
	# prespawn set amount of stars
	# number needs tweaking
	prespawn(600)
	
func prespawn(count):
	# create count stars
	for _i in range(count):
		var s = star.instance()
		
		# move to random position
		s.position.x = rand_range(-3, get_viewport().size.x + 3)
		s.position.y = rand_range(-3, get_viewport().size.y + 3)
		
		# add to scene 
		get_tree().current_scene.call_deferred("add_child", s)

func _on_Timer_timeout():
	create_star()
	
func create_star():
	# create instance
	var s = star.instance()
	
	# set to a random position
	s.position.x = rand_range(-3, get_viewport().size.x + 3)
	s.position.y = -50
	
	# add star to scene
	get_tree().current_scene.add_child(s)
