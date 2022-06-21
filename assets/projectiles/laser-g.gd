extends Area2D

# basic spaceship projectile manager

export (float) var move_speed
export (PackedScene) var explosion

var damage

func _ready():
	var effects = $Effects
	effects.play()
	remove_child(effects)
	get_tree().current_scene.add_child(effects)
	effects.position = global_position

func _process(delta):
	# move projectile up
	position.y -= move_speed * delta
	
	# make sure projectile is still in view
	if position.y < -50:
		queue_free()


func _on_laser_area_entered(area : Area2D):
	if area.is_in_group("asteroids") or area.is_in_group("enemies"):
		# deal damage
		area.health -= clamp(damage * get_tree().current_scene.health_speed_up / 2, damage, 100)
		
		# explode
		var e = explosion.instance()
		e.position = position
		e.get_child(0).volume = -25
		get_tree().current_scene.add_child(e)
		
		queue_free()
