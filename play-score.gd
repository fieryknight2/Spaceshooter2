extends Node2D

var score = 0
export (float) var speed_up
var speed_scale = 1

var rom = false

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


func _on_Menu_pressed():
	rom = false
	$AnimationPlayer.play("finish")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "finish":
		if rom:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene("res://Menu.tscn")
	if anim_name == "player_dead":
		$UI/Panel/Restart.grab_focus()
