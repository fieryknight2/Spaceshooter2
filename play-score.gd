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
onready var boss_health = get_node(boss_health_path)

export (Color) var max_health_color
export (Color) var no_health_color
export (Color) var max_energy_color
export (Color) var no_energy_color

export (float) var animation_speed

var player_alive = true
var player = null
var rom = false
var boss = null
var ship_names = ["Swallow", "Swift", "Falcon"]
var e_health_value
var e_energy_value
var die_once = false

onready var Health : ProgressBar = get_node("%Health")
onready var Energy : ProgressBar = get_node("%Energy")

func _ready():
	get_tree().paused = false
	var ss = spaceships[Globals.ship].instance()
	score_mod = ss.score_modifier
	add_child(ss)
	player = ss
	
	Health.max_value = player.max_health
	Health.value = player.health
	e_health_value = Health.value 
	
	Energy.max_value = player.max_energy
	Energy.value = player.energy
	e_energy_value = Energy.value
	
	
func _process(delta):
	score = int(score)
	$UI/HUD/Score/Score.text = String(score)
	if len(Globals.high_scores) and score > Globals.high_scores[0]["score"]:
		$UI/HUD/Score/High.visible = true
	
	if is_instance_valid(player):
		if e_health_value != player.health:
			var t = 1
			if e_health_value < player.health: t = 2
			var duration = animation_speed / t / abs(e_health_value - player.health / Health.max_value) 
			e_health_value = player.health
			t = create_tween().set_ease(Tween.EASE_IN).tween_property(Health, 
									"value", e_health_value, duration)
		
		if e_energy_value != player.energy:
			var t = 1
			if e_energy_value < player.energy: t = 2
			var duration = animation_speed / t / abs(e_energy_value - player.energy / Energy.max_value)
			e_energy_value = player.energy
			t = create_tween().set_ease(Tween.EASE_IN).tween_property(Energy,
									"value", e_energy_value, duration)
		

		Energy.get("custom_styles/fg").bg_color = no_energy_color.linear_interpolate( 
								max_energy_color, Energy.value / Energy.max_value)
		Health.get("custom_styles/fg").bg_color = no_health_color.linear_interpolate(
								max_health_color, Health.value / Health.max_value)
	elif !die_once:
		create_tween().kill()
		die_once = true
		var t = 5
		var h_duration = animation_speed / t / (e_health_value / Health.max_value) 
		var e_duration = animation_speed / t / (e_energy_value / Energy.max_value)
		t = create_tween().tween_property(Health, "value", 0.0, h_duration)
		t = create_tween().tween_property(Energy, "value", 0.0, e_duration)
	
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
	
	if score > 0:
		Globals.high_scores.append({"ship": ship_names[Globals.ship], "score": score})
	Globals.process_scores()


func _on_Menu_pressed():
	rom = false
	$AnimationPlayer.play("finish")
	
	if score > 0:
		Globals.high_scores.append({"ship": ship_names[Globals.ship], "score": score})
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
