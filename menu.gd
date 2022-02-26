extends Control

export (PackedScene) var play_scene
export (PackedScene) var score_p
export (NodePath) var scores_path

onready var scores = get_node(scores_path)

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
		"description": "A slow sniper with medium health and high damage, with 1 Super Laser"
	}
]

var speed_scale = 1
var cship = Globals.ship
var mode

func _ready():
	get_tree().paused = false
	$AnimationPlayer.play("enter")
	
	Globals.process_scores()
	for score in Globals.high_scores:
		var c = score_p.instance()
		
		c.highscore_name = score["name"]
		c.highscore_score = score["score"]
		
		scores.add_child(c)

func _on_Play_pressed():
	$AnimationPlayer.play("exit")
	mode = "play"

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
		if mode == "play":
# warning-ignore:return_value_discarded
			get_tree().change_scene_to(play_scene)
		if mode == "ships":
			# Star equipped ship
			$AnimationPlayer.play("show_ships")
		if mode == "scores":
			$AnimationPlayer.play("Show Scores")
	if anim_name == "enter":
		$Buttons/Play.grab_focus()
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

