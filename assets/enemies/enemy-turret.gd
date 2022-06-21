extends Sprite

onready var gun = $Gun
onready var fp = $Gun/Position2D

func _process(_delta):
	if get_tree().current_scene.has_player():
		gun.look_at(get_tree().current_scene.get_player().global_position)
