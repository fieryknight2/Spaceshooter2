extends Sprite2D

# quick planet movement script
var move_speed
var rotate_speed

func _process(delta):
	# move and rotate planet
	position.y += move_speed * delta * get_tree().current_scene.speed_scale
	rotation_degrees += rotate_speed * delta
	
	# check if planet is outside view
	if position.y > get_viewport().size.y + 300:
		queue_free()
