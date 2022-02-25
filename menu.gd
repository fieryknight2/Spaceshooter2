extends Control
export (PackedScene) var play_scene

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
	}
]

var speed_scale = 1
var cship = 0
var mode

func _ready():
	$AnimationPlayer.play("enter")

func _on_Play_pressed():
	$AnimationPlayer.play("exit")
	mode = "play"

func _on_Ships_pressed():
	$AnimationPlayer.play("exit")
	mode = "ships"

func _on_Quit_pressed():
	get_tree().quit()


func _on_Highscores_pressed():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		if mode == "play":
# warning-ignore:return_value_discarded
			get_tree().change_scene_to(play_scene)
		if mode == "ships":
			# Star equipped ship
			$AnimationPlayer.play("show_ships")
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
