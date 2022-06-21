extends AudioStreamPlayer2D

func _on_Effects_finished():
	queue_free()
