extends Sprite2D

@onready var gun = $Gun
@onready var fp = $Gun/Marker2D

func _process(_delta):
	if get_tree().current_scene.has_player():
		gun.look_at(get_tree().current_scene.get_player().global_position)
