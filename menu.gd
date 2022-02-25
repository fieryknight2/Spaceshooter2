extends Control

export (PackedScene) var play_scene

var speed_scale = 1

var mode

func _ready():
	$AnimationPlayer.play("enter")

func _on_Play_pressed():
	$AnimationPlayer.play("exit")
	mode = play_scene

func _on_Ships_pressed():
	pass # not implemented yet


func _on_Achievements_pressed():
	pass # not implemented yet


func _on_Quit_pressed():
	get_tree().quit()


func _on_Highscores_pressed():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		get_tree().change_scene_to(mode)
	if anim_name == "enter":
		$Buttons/Play.grab_focus()
