extends Node

var ship = 0
var high_scores = []
var prev_name = ""

var c_version = 0.4
var last_break = 0.39
var endless_play = false
var difficulty = 0

func _enter_tree():
	if not FileAccess.file_exists("user://data.save"):
		return
	
	var x = FileAccess.open("user://data.save", FileAccess.READ)
	
	var version = x.get_line()
	if !version.is_valid_float() or float(version) <= last_break:
		if !version.is_valid_float():
			print("Save file version is too old, deleting...")
		else:
			print("Save file version (" + version + ") is too old, deleting...")
			DirAccess.remove_absolute("user://data.save")
		return
		
	var test_json_conv = JSON.new()
	test_json_conv.parse(x.get_line())
	high_scores = test_json_conv.get_data()
	ship = int(x.get_line())
	prev_name = x.get_line()
	
	process_scores()
	
func _exit_tree():
	var x = FileAccess.open("user://data.save", FileAccess.WRITE)
	x.store_line(String(c_version))
	x.store_line(JSON.new().stringify(high_scores))
	x.store_line(String(ship))
	x.store_line(prev_name)

func process_scores():
	high_scores.sort_custom(Callable(self, "sort_scores"))
	if high_scores.size() > 15:
		high_scores.resize(15)
	
func sort_scores(a, b):
	if a["score"] > b["score"]:
		return true
	return false
