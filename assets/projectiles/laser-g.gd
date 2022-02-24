extends Area2D

# basic spaceship projectile manager

export (float) var move_speed
export (PackedScene) var explosion

var damage

func _process(delta):
	# move projectile up
	position.y -= move_speed * delta
	
	# make sure projectile is still in view
	if position.y < -25:
		queue_free()


func _on_laser_area_entered(area):
	if area.is_in_group("asteroids") or area.is_in_group("enemies"):
		# deal damage
		area.health -= damage
		
		# explode
		var e = explosion.instance()
		e.position = position
		get_tree().current_scene.add_child(e)
		
		queue_free()
