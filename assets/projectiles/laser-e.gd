extends Area2D

# basic spaceship projectile manager

export (float) var move_speed
export (PackedScene) var explosion

var damage

func _process(delta):
	# move projectile down
	position += Vector2(0,move_speed * delta).rotated(rotation)
	
	# make sure projectile is still in view
	if position.y > get_viewport().size.y + 50:
		queue_free()


func _on_laser_area_entered(area):
	if area.is_in_group("ships"):
		# deal damage
		area.health -= damage
		
		# explode
		var e = explosion.instance()
		e.position = position
		get_tree().current_scene.add_child(e)
		
		queue_free()
