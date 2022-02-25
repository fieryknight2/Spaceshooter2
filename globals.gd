extends Node

var ship = 0
var high_scores = []

func _enter_tree():
	var x = File.new()
	if not x.file_exists("user://data.save"):
		return
		
	x.open("user://data.save", File.READ)
	high_scores = parse_json(x.get_line())
	ship = int(x.get_line())
	
func _exit_tree():
	var x = File.new()
	x.open("user://data.save", File.WRITE)
	x.store_line(to_json(high_scores))
	x.store_line(String(ship))
