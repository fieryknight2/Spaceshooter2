extends Control

@export var play_scene : PackedScene
@export var score_p : PackedScene
@export var scores_path : NodePath

@onready var scores = get_node(scores_path)

var ship_data = [
	{
		"name": "Swallow",
		"image": preload("res://assets/spaceships/spaceship.png"),
		"description": "Pretty balanced ship with four Single Lasers. Moderate speed and agility, with good shield"
	},
	{
		"name": "Swift",
		"image": preload("res://assets/spaceships/spaceship-2.png"),
		"description": "Weak but fast ship, with two Triple Lasers for blasting asteroids in style."
	},
	{
		"name": "Falcon",
		"image": preload("res://assets/spaceships/spaceship-3.png"),
		"description": "A slow sniper with high health and high damage, with 1 Super Laser"
	}
]

var speed_scale = 1
var cship = Globals.ship
var mode
var difficulty = 0
var level = 0

func _ready():
	$Buttons.position = Vector2(-1000, -1000)
	get_tree().paused = false
	$AnimationPlayer.play("enter")
	# $MusicOff.play("Start Music")
	
	Globals.process_scores()
	for score in Globals.high_scores:
		var c = score_p.instantiate()
		
		c.highscore_ship = score["ship"]
		c.highscore_score = score["score"]
		
		scores.add_child(c)
	print("Hello World")

func _process(_delta):
	if $Music.playing == false:
		$Music.play()

func _on_Play_pressed():
	#$AnimationPlayer.play("exit")
	#mode = "choose_level"
	pass

func _on_Ships_pressed():
	$AnimationPlayer.play("exit")
	mode = "ships"

func _on_Quit_pressed():
	get_tree().quit()


func _on_Highscores_pressed():
	$AnimationPlayer.play("exit")
	mode = "scores"

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		if mode == "choose_difficulty":
			$AnimationPlayer.play("Show Difficulties")
		if mode == "choose_level":
			#$AnimationPlayer.play("Show Levels 1")
			pass
		if mode == "ships":
			# Star equipped ship
			$AnimationPlayer.play("show_ships")
		if mode == "scores":
			$AnimationPlayer.play("Show Scores")
	if anim_name == "enter":
		$Buttons/EndlessPlay.grab_focus()
	if anim_name == "hide_ships":
		if mode == "menu":
			$AnimationPlayer.play("enter")
		else:
			# manage ship chosen
			$AnimationPlayer.play("overview_ship")
	if anim_name == "show_ships":
		$Ships/Back.grab_focus()
	if anim_name == "hide_overview":
		$AnimationPlayer.play("show_ships")
	if anim_name == "overview_ship":
		$ShipOverview/VManage/Buttons/Equip.grab_focus()
	if anim_name == "Hide Scores":
		$AnimationPlayer.play("enter")
	if anim_name == "Show Scores":
		$HighScores/Container/Back.grab_focus()
	if anim_name == "Show Difficulties":
		$Difficulties/VBox/Easy.grab_focus()
	if anim_name == "Hide Difficulties":
		if mode == "endless":
			$MusicOff.play("Kill Music")
			Globals.difficulty = difficulty
			Globals.endless_play = true
# warning-ignore:return_value_discarded
			get_tree().change_scene_to_packed(play_scene)
		else:
			$AnimationPlayer.play("enter")

func _on_Back_pressed():
	$AnimationPlayer.play("hide_ships")
	mode = "menu"

func _on_Back_Overview_pressed():
	$AnimationPlayer.play("hide_overview")


func _on_Equip_pressed():
	Globals.ship = cship
	$AnimationPlayer.play("hide_overview")

func set_overview():
	$ShipOverview/VManage/Description.text = ship_data[cship]["description"]
	$ShipOverview/VManage/Overview/Name.text = ship_data[cship]["name"]
	$ShipOverview/VManage/Overview/Image.texture = ship_data[cship]["image"]

func _on_S1_pressed():
	cship = 0
	set_overview()
	$AnimationPlayer.play("hide_ships")
	mode = "overview"

func _on_S2_pressed():
	cship = 1
	set_overview()
	$AnimationPlayer.play("hide_ships")
	mode = "overview"

func _on_S3_pressed():
	cship = 2
	set_overview()
	$AnimationPlayer.play("hide_ships")
	mode = "overview"

func _on_Back_Highscores_pressed():
	$AnimationPlayer.play("Hide Scores")

func _on_Music_finished():
	$Music.play()


func _on_EndlessPlay_pressed():
	$AnimationPlayer.play("exit")
	mode = "choose_difficulty"


func _on_Easy_pressed():
	$AnimationPlayer.play("Hide Difficulties")
	mode = "endless"
	difficulty = 1


func _on_Medium_pressed():
	$AnimationPlayer.play("Hide Difficulties")
	mode = "endless"
	difficulty = 2


func _on_Hard_pressed():
	$AnimationPlayer.play("Hide Difficulties")
	mode = "endless"
	difficulty = 3


func _on_Impossible_pressed():
	$AnimationPlayer.play("Hide Difficulties")
	mode = "endless"
	difficulty = 4


func _on_Difficulties_Back_pressed():
	$AnimationPlayer.play("Hide Difficulties")
	mode = "menu"
