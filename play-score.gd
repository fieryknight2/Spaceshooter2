extends Node2D

export (Array, PackedScene) var spaceships
var score = 0
export (float) var speed_up
var speed_scale = 1
export (NodePath) var text_name_path
onready var text_name = get_node(text_name_path)

var rom = false

func _ready():
	var ss = spaceships[Globals.ship].instance()
	add_child(ss)
	
	text_name.text = Globals.prev_name

func _process(delta):
	score = int(score)
	$UI/Score.text = String(score)
	
	speed_scale += delta * speed_up

func player_die():
	$AnimationPlayer.play("player_dead")
	
	$EnemySpawner.queue_free()
	$AsteroidSpawner.queue_free()
	$PlanetSpawner.queue_free()

func _on_Restart_pressed():
	rom = true
	$AnimationPlayer.play("finish")
	
	Globals.prev_name = text_name.text
	Globals.high_scores.append({"name": text_name.text, "score": score})
	Globals.process_scores()


func _on_Menu_pressed():
	rom = false
	$AnimationPlayer.play("finish")
	
	Globals.prev_name = text_name.text
	Globals.high_scores.append({"name": text_name.text, "score": score})
	Globals.process_scores()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "finish":
		if rom:
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
		else:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Menu.tscn")
	if anim_name == "player_dead":
		$UI/Panel/container/Restart.grab_focus()
