extends AnimatedSprite2D

# simple explosion script

var volume : float = -30

func _ready(): 
	play("explosion")
	
	var effects = $Effects
	effects.volume_db = volume
	effects.play()
	remove_child(effects)
	get_tree().current_scene.add_child(effects)
	effects.position = global_position


func _on_explosion_animation_finished():
	queue_free()


func _on_explode_animation_finished():
	queue_free()

