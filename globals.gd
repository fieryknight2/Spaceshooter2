extends Node

var ship = 0
var high_scores = []
var prev_name = ""

var c_version = 0.4
var last_break = 0.39
var endless_play = false
var difficulty = 0

func _enter_tree():
	var x = File.new()
	if not x.file_exists("user://data.save"):
		return
	
	x.open("user://data.save", File.READ)
	
	var version = x.get_line()
	if !version.is_valid_float() or float(version) <= last_break:
		if !version.is_valid_float():
			print("Save file version is too old, deleting...")
		else:
			print("Save file version (" + version + ") is too old, deleting...")
		var _c = Directory.new().remove("user://data.save")
		return
		
	high_scores = parse_json(x.get_line())
	ship = int(x.get_line())
	prev_name = x.get_line()
	
	process_scores()
	
func _exit_tree():
	var x = File.new()
	x.open("user://data.save", File.WRITE)
	x.store_line(String(c_version))
	x.store_line(to_json(high_scores))
	x.store_line(String(ship))
	x.store_line(prev_name)

func process_scores():
	high_scores.sort_custom(self, "sort_scores")
	if high_scores.size() > 15:
		high_scores.resize(15)
	
func sort_scores(a, b):
	if a["score"] > b["score"]:
		return true
	return false
