extends Area2D

# basic spaceship projectile manager

@export var move_speed : float
@export var explosion : PackedScene

var damage

func _ready():
	var effects = $Effects
	effects.play()
	remove_child(effects)
	get_tree().current_scene.add_child(effects)
	effects.position = global_position
	
func _process(delta):
	# move projectile down
	position += Vector2(0,move_speed * delta).rotated(rotation)
	
	# make sure projectile is still in view
	if position.y > get_viewport().size.y + 50 or position.y < 0:
		queue_free()


func _on_laser_area_entered(area):
	if area.is_in_group("ships"):
		# deal damage
		area.health -= damage
		
		# explode
		var e = explosion.instantiate()
		e.position = position
		e.get_child(0).volume = -25
		area.add_child(e)
		
		queue_free()
