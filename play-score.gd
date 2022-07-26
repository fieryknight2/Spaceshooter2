extends Node2D

export (Array, PackedScene) var spaceships
var score = 0
export (float) var speed_up
export (float) var health_speed_up
var score_mod = 1
var speed_scale = 1
var health_scale = 1
export (NodePath) var text_name_path
export (NodePath) var text_name_2_path
export (NodePath) var boss_health_path
onready var text_name = get_node(text_name_path)
onready var text_name_2 = get_node(text_name_2_path)
onready var boss_health = get_node(boss_health_path)

var player_alive = true
var player = null
var rom = false
var boss = null

func _ready():
	get_tree().paused = false
	var ss = spaceships[Globals.ship].instance()
	score_mod = ss.score_modifier
	add_child(ss)
	player = ss
	
	text_name.text = Globals.prev_name
	text_name_2.text = Globals.prev_name
	
	$UI/HUD/Bars/Health.max_value = ss.max_health
	$UI/HUD/Bars/Health.value = player.health
	
	# $UI/HUD/Bars/Energy.max_value = ss.max_energy

# warning-ignore:unused_argument
func _process(delta):
	score = int(score)
	$UI/HUD/Score/Score.text = String(score)
	if len(Globals.high_scores) and score > Globals.high_scores[0]["score"]:
		$UI/HUD/Score/High.visible = true
	
	$UI/HUD/Bars/Health.value = player.health
	
	speed_scale += delta * speed_up
	
	health_scale += delta * health_speed_up
	
	if Input.is_action_just_pressed("pause") and player_alive:
		get_tree().paused = true
		$AnimationPlayer.play("show_pause")
	
	if boss != null:
		boss_health.value = boss.health
			

func play():
	if player_alive and $AnimationPlayer.is_playing() == false:
		$AnimationPlayer.play("hide_pause")
	
func player_die():
	player_alive = false
	$AnimationPlayer.play("player_dead")
	
	$EnemySpawner.queue_free()
	$PlanetSpawner.queue_free()

func _on_Restart_pressed():
	rom = true
	$AnimationPlayer.play("finish")
	
	Globals.prev_name = text_name.text
	if score > 0:
		Globals.high_scores.append({"name": text_name.text, "score": score})
	Globals.process_scores()


func _on_Menu_pressed():
	rom = false
	$AnimationPlayer.play("finish")
	
	Globals.prev_name = text_name.text
	if score > 0:
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
	if anim_name == "hide_pause":
		get_tree().paused = false
	if anim_name == "show_pause":
		$UI/Pause/container/Continue.grab_focus()

func _on_Continue_pressed():
	$AnimationPlayer.play("hide_pause")

func has_player():
	return player_alive
	
func get_player():
	return player
	
func disable_asteroids(disable):
	if disable:
		$AsteroidSpawner/Timer.stop()
		$EnemySpawner/E1.stop()
		$EnemySpawner/E2.stop()
	else:
		$AsteroidSpawner/Timer.start()
		$EnemySpawner/E1.start()
		$EnemySpawner/E2.start()
		
func start_boss(b):
	disable_asteroids(true)
	boss = b
	boss_health.max_value = boss.max_health
	boss_health.value = boss.health
	boss_health.visible = true

func end_boss():
	disable_asteroids(false)
	boss = null
	boss_health.visible = false
