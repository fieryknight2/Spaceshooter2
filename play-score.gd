extends Node2D

@export var spaceships : Array[PackedScene]
var score = 0
@export var speed_up : float
@export var health_speed_up : float
var score_mod = 1
var speed_scale = 1
var health_scale = 1
@export var text_name_path : NodePath
@export var text_name_2_path : NodePath
@export var boss_health_path : NodePath
@onready var boss_health = get_node(boss_health_path)

@export var max_health_color : Color
@export var middle_health_color : Color
@export var no_health_color : Color
@export var max_energy_color : Color
@export var no_energy_color : Color

@export var difficulties : Array[float]

@export var animation_speed : float

var player_alive = true
var player = null
var rom = false
var boss = null
var ship_names = ["Swallow", "Swift", "Falcon"]
var e_health_value
var e_energy_value
var max_energy_value
var max_health_value
var die_once = false

var healthTween : Tween
var energyTween : Tween

@onready var Health : ProgressBar = get_node("%Health")
@onready var Energy : ProgressBar = get_node("%Energy")

var e_stylebox_fill : StyleBoxFlat
var h_stylebox_fill : StyleBoxFlat

func _ready():
	get_tree().paused = false
	var ss = spaceships[Globals.ship].instantiate()
	score_mod = ss.score_modifier
	add_child(ss)
	player = ss
	
	Health.max_value = player.max_health
	Health.value = player.health
	max_health_value = player.max_health
	e_health_value = Health.value 
	
	Energy.max_value = player.max_energy
	Energy.value = player.energy
	max_energy_value = player.max_energy
	e_energy_value = Energy.value
	
	speed_scale = difficulties[Globals.difficulty - 1]
	
	healthTween = get_tree().create_tween()
	energyTween = get_tree().create_tween()
	
	energyTween.set_ease(Tween.EASE_IN)
	energyTween.set_trans(Tween.TRANS_LINEAR)
	
	healthTween.set_ease(Tween.EASE_IN)
	healthTween.set_trans(Tween.TRANS_LINEAR)
	
	e_stylebox_fill = StyleBoxFlat.new()
	h_stylebox_fill = StyleBoxFlat.new()
	
	e_stylebox_fill.corner_radius_bottom_left = 7
	e_stylebox_fill.corner_radius_top_left = 7
	h_stylebox_fill.corner_radius_top_right = 7
	h_stylebox_fill.corner_radius_bottom_right = 7
	e_stylebox_fill.set_border_width_all(1)
	h_stylebox_fill.set_border_width_all(1)
	e_stylebox_fill.border_color = Color(255,255,255)
	h_stylebox_fill.border_color = Color(255,255,255)
	
	e_stylebox_fill.bg_color = max_energy_color
	h_stylebox_fill.bg_color = max_health_color
	
	Energy.add_theme_stylebox_override("fill", e_stylebox_fill)
	Health.add_theme_stylebox_override("fill", h_stylebox_fill)
	
	
func _process(delta):
	score = int(score)
	$UI/HUD/Score/Score.text = str(score)
	if len(Globals.high_scores) and score > Globals.high_scores[0]["score"]:
		$UI/HUD/Score/High.visible = true
	
	if is_instance_valid(player):
		if e_health_value != player.health:
			var t = 1
			if e_health_value < player.health: t = 2
			var duration = animation_speed / t / abs(e_health_value - player.health / Health.max_value) 
			e_health_value = player.health
			
			if healthTween:
				healthTween.kill()
			healthTween = get_tree().create_tween()
			healthTween.tween_property(Health, "value", e_health_value, duration *
										(e_health_value/max_health_value))
			healthTween.play()
			
		
		if e_energy_value != player.energy:
			var t = 1
			if e_energy_value < player.energy: t = 2
			var duration = animation_speed / t / abs(e_energy_value - player.energy / Energy.max_value)
			e_energy_value = player.energy
			
			if energyTween:
				energyTween.kill()
			energyTween = get_tree().create_tween()
			energyTween.tween_property(Energy, "value", e_energy_value,duration * 
										(e_energy_value/max_energy_value))
			energyTween.play()
			
	elif !die_once:
		die_once = true
		var t = 5
		var h_duration = animation_speed / t / (e_health_value / max_health_value) 
		var e_duration = animation_speed / t / (e_energy_value / max_energy_value)
		
		if healthTween:
			healthTween.kill()
		healthTween = get_tree().create_tween()
		healthTween.tween_property(Health, "value", 0.0, abs(h_duration))
		healthTween.play()
		
		if energyTween:
			energyTween.kill()
		energyTween = get_tree().create_tween()
		energyTween.tween_property(Energy, "value", 0.0, abs(e_duration))
		energyTween.play()
		
	e_stylebox_fill.bg_color = no_energy_color.lerp( 
							max_energy_color, Energy.value / Energy.max_value)
			
	if (Health.value / Health.max_value) > 0.5:
		var color = middle_health_color.lerp(max_health_color, (Health.value - 
											(Health.max_value / 2)) / 
											(Health.max_value - (Health.max_value / 2)))
		h_stylebox_fill.bg_color = color
	else:
		var color = no_health_color.lerp(middle_health_color, Health.value 
										/ (Health.max_value - (Health.max_value / 2)))
		h_stylebox_fill.bg_color = color
	
	
	# speed_scale += delta * speed_up
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
			get_tree().change_scene_to_file("res://Menu.tscn")
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
