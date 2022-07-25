extends Panel

func _process(_delta):
	if get_tree().paused == true and visible:
		if Input.is_action_just_pressed("pause"):
			get_tree().current_scene.play()
