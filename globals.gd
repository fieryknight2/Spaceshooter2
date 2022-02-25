extends Node

var ship = 0
var high_scores = []
var prev_name = ""

func _enter_tree():
	var x = File.new()
	if not x.file_exists("user://data.save"):
		return
		
	x.open("user://data.save", File.READ)
	high_scores = parse_json(x.get_line())
	ship = int(x.get_line())
	prev_name = x.get_line()
	
	process_scores()
	print(high_scores)
	
func _exit_tree():
	var x = File.new()
	x.open("user://data.save", File.WRITE)
	x.store_line(to_json(high_scores))
	x.store_line(String(ship))
	x.store_line(prev_name)

func process_scores():
	high_scores.sort_custom(self, "sort_scores")
	if high_scores.size() > 10:
		high_scores.resize(10)
	
func sort_scores(a, b):
	if a["score"] > b["score"]:
		return true
	return false
