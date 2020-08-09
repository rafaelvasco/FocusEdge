extends Node2D

export(PackedScene) var game

var game_instance: Node = null
var bonus_instances = {}
var current_bonus = null

# Called when the node enters the scene tree for the first time.
func _ready():
	game_instance = game.instance()
	game_instance.connect("bonus_activated", self, "_on_bonus_activated")
	add_child(game_instance)
	

func _on_bonus_activated(bonus_name):
	
	if not bonus_instances.has(bonus_name):
		print("Loading Bonus: ", bonus_name)
		var bonus_scene = load("res://" + "/Bonus/" + bonus_name + ".tscn")
		self.bonus_instances[bonus_name] = bonus_scene.instance()
	
	_go_to_bonus(bonus_instances[bonus_name])
		

func return_to_game():
	remove_child(self.current_bonus)
	add_child(game_instance)
	game_instance.return_from_bonus()
	self.current_bonus = null


func _go_to_bonus(bonus_instance):
	self.current_bonus = bonus_instance
	remove_child(game_instance)
	add_child(bonus_instance)
	bonus_instance.setup()
	
	

