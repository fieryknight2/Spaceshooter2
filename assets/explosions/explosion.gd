extends AnimatedSprite

# simple explosion script

func _ready(): 
	play("explosion")


func _on_explosion_animation_finished():
	queue_free()


func _on_explode_animation_finished():
	queue_free()
