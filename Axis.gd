extends Node2D

onready var buttons = $CanvasLayer/Control/AxisButtons

const press_effect = preload("res://AxisEffect.tscn")

signal symbol_emitted(symbol, direction)
signal direction_targeted(direction)
signal phrase_finished()

export var target_mode = Common.WordMode.Letters
var current_target_enemy = null
var current_word_index = 0

func _ready():
	clear_axis()
	randomize()


func set_current_target_enemy(enemy):
	
	self.current_target_enemy = enemy
	populate_axis_elements()
	


func clear_axis():
	match self.target_mode:
		Common.WordMode.Letters:
			buttons.get_node("Left/Letters/Label").text = ""
			buttons.get_node("Right/Letters/Label").text = ""
			buttons.get_node("Up/Letters/Label").text = ""
			buttons.get_node("Down/Letters/Label").text = ""
		Common.WordMode.Colors:
			pass


func update_visuals():
	
	if self.current_target_enemy != null:
		match self.target_mode:
			Common.WordMode.Letters:
				for btn in buttons.get_children():
					btn.get_node("Letters").show()
					btn.get_node("Colors").hide()
			Common.WordMode.Colors:
				for btn in buttons.get_children():
					btn.get_node("Letters").hide()
					btn.get_node("Colors").show()
	else:
		for btn in buttons.get_children():
			btn.get_node("Letters").hide()
			btn.get_node("Colors").hide()


func populate_axis_elements():
	
	var word = self.current_target_enemy.word
	
	if word.empty():
		clear_axis()
		return
	
	match self.current_enemy.mode:
		Common.WordMode.Letters:
			
			var target_direction = Common.GetRandomDirection()
		
			var current_target_letter = word[self.current_word_index]
			
			var generated_letters = []
			
			generated_letters.push_back(current_target_letter)
			
			var random_placeholder_letter = null
			
			match target_direction:
				Common.Directions.LEFT: 
					_set_letter("Left", current_target_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Right", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Up", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Down", random_placeholder_letter)
					
				Common.Directions.RIGHT: 
					_set_letter("Right", current_target_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Left", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Up", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Down", random_placeholder_letter)
					
				Common.Directions.UP: 
					_set_letter("Up", current_target_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Right", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Left", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Down", random_placeholder_letter)
					
				Common.Directions.DOWN: 
					_set_letter("Down", current_target_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Right", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Up", random_placeholder_letter)
					generated_letters.push_back(random_placeholder_letter)
					
					random_placeholder_letter = _get_random_letter(generated_letters)
					_set_letter("Left", random_placeholder_letter)
			
		Common.WordMode.Colors:
			pass
	



func _set_letter(axis, letter):
	
	var target = buttons.get_node(axis + "/Letters/Label")
	
	if letter != " ":
		target.text = letter
	else:
		target.text = "_"


func _get_random_letter(generated_letters):
	
	var random_letter = Common.GetRandomDigit()
	var clashes = 0
	
	for letter in generated_letters:
		if letter == random_letter:
			random_letter = Common.GetRandomDigit()
			clashes += 1
			
	
	while clashes > 0:
		clashes = 0
		for letter in generated_letters:
			if letter == random_letter:
				random_letter = Common.GetRandomDigit()
				clashes += 1
	
	
	return random_letter


func _input(event):
	
	if event.is_action_pressed("AxisLeft"):
		trigger_axis("Left")
	if event.is_action_pressed("AxisRight"):
		trigger_axis("Right")
	if event.is_action_pressed("AxisUp"):
		trigger_axis("Up")
	if event.is_action_pressed("AxisDown"):
		trigger_axis("Down")



func trigger_axis(direction):
	
	var axis_element = buttons.get_node(direction)
	var spawn_effect_pos = axis_element.get_node("SpawnPoint").position
	var effect = press_effect.instance()
	axis_element.add_child(effect)
	effect.position = spawn_effect_pos
	
	match self.target_mode:
		Common.WordMode.Letters:
			var chosen_symbol = buttons.get_node(direction + "/Letters/Label").text
			emit_signal("symbol_emitted", chosen_symbol, direction)
			
			if self.current_target_enemy != null:
				var target_word = self.current_target_enemy.word
				if chosen_symbol == target_word[self.current_word_index]:
					if self.current_word_index < target_word.length()-1:
						self.current_word_index += 1
			
		Common.WordMode.Colors:
			pass
	
	
	
		

func flash_error():
	$AnimationPlayer.play("FlashError")


func _process(delta):
	pass
	
