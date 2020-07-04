extends Node2D

onready var buttons = $AxisButtons
onready var bullet_spawn_origin = $BulletSpawnOrigin
onready var damage_timer = $DamageTimer
onready var power_up_aura = $PowerUpAura
onready var damage_audio = $DamageAudio
onready var tween = $Tween
onready var trail = $Trail

const press_effect = preload("res://AxisEffect.tscn")

const ANIMATE_GROW_TIME = 0.25
const BASE_SCALE = 0.25
const BASE_POWERUP_ANIM_SCALE = 3
const TARGET_POWERUP_ANIM_SCALE = 1.0

signal direction_targeted(direction)
signal phrase_finished
signal camera_shake_requested

export var target_mode = Common.WordMode.Letters

var current_target_enemy = null
var current_word_index := 0
var dragging := false
var choosing_symbol := false
var last_generated_target_direction = null
var collision_active := true
var last_position = Vector2.ZERO


func _ready():
	scale = Vector2(BASE_SCALE, BASE_SCALE)
	$Trail.process_material.scale = BASE_SCALE
	$AnimationPlayer.get_animation("PowerUp").track_set_key_value(0, 0, BASE_POWERUP_ANIM_SCALE)
	clear_target()
	trail.emitting = false
	randomize()


func set_current_target_enemy(enemy):
	
	self.current_target_enemy = enemy
	self.current_target_enemy.set_focused(true)
	self.choosing_symbol = true
	self.current_word_index = 0
	enemy.connect("died", self, "_on_current_target_dead")
	populate_axis_elements()
	update_visuals()
	

func clear_target():
	if self.current_target_enemy != null:
		self.current_target_enemy.set_focused(false)
		
	self.current_target_enemy = null
	self.current_word_index = 0
	self.choosing_symbol = false
	self.update_visuals()


func update_visuals():
	
	if self.current_target_enemy != null:
		_animate_to_scale(TARGET_POWERUP_ANIM_SCALE)
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
		_animate_to_scale(BASE_SCALE)
		for btn in buttons.get_children():
			btn.get_node("Letters").hide()
			btn.get_node("Colors").hide()


func _animate_to_scale(target: float):
	if tween.is_active():
		tween.stop_all()
	tween.interpolate_property(self, "scale", self.scale, Vector2(target, target), ANIMATE_GROW_TIME)
	tween.start()



func populate_axis_elements():
	
	var word = self.current_target_enemy.word
	
	if word.empty():
		clear_target()
		return
	
	match self.current_target_enemy.mode:
		Common.WordMode.Letters:
			
			var target_direction = Common.GetRandomDirection()
			
			while target_direction == self.last_generated_target_direction:
				target_direction = Common.GetRandomDirection()
				
			self.last_generated_target_direction = target_direction
		
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


func trigger_axis(direction):
	
	if not self.choosing_symbol:
		return
	
	spawn_axis_effect(direction)
	
	match self.target_mode:
		Common.WordMode.Letters:
			trigger_letter(direction)
			
		Common.WordMode.Colors:
			pass


func trigger_letter(direction):
	var chosen_symbol = buttons.get_node(direction + "/Letters/Label").text
	if self.current_target_enemy != null:
		var target_word = self.current_target_enemy.word
		if chosen_symbol == target_word[self.current_word_index]:
			if self.current_word_index < target_word.length()-1:
				self.current_word_index += 1
				populate_axis_elements()
			else:
				emit_signal("phrase_finished")
				powerup()
				
				
			self.current_target_enemy.get_hit()
				
		else:
			damage()


func spawn_axis_effect(direction):
	var axis_element = buttons.get_node(direction)
	var spawn_effect_pos = axis_element.get_node("SpawnPoint").position
	var effect = press_effect.instance()
	axis_element.add_child(effect)
	effect.position = spawn_effect_pos
	

func damage():
	print("Damage")
	$AnimationPlayer.play("Damage")
	damage_timer.start(1)
	self.collision_active = false
	emit_signal("camera_shake_requested")
	damage_audio.play()


func powerup():
	power_up_aura.show()
	$AnimationPlayer.play("PowerUp")
	damage_timer.start(1)
	_center_on_mouse()
	self.collision_active = false


func _on_current_target_dead():
	self.clear_target()
	

func _on_mouse_input(viewport, event, shape_idx):
	pass
		

func _input(event):
	
	if event is InputEventMouseButton:
		if not event.pressed and self.dragging:
			self.dragging = false
			self.choosing_symbol = false
			self.clear_target()	
				
	elif event is InputEventMouseMotion:
		if not self.dragging:
			return
		
		if not self.choosing_symbol:
				
			self.position += event.get_relative()
			
			if self.position.distance_to(self.last_position) > 0:
				trail.emitting = true
			else:
				trail.emitting = false
			
			self.last_position = self.position
			
		


func _on_mouse_enter_left_axis():
	if not self.choosing_symbol:
		return
	trigger_axis("Left")


func _on_mouse_enter_right_axis():
	if not self.choosing_symbol:
		return
	trigger_axis("Right")


func _on_mouse_enter_up_axis():
	if not self.choosing_symbol:
		return
	trigger_axis("Up")


func _on_mouse_enter_down_axis():
	if not self.choosing_symbol:
		return
	trigger_axis("Down")


func _on_CollisionArea_body_entered(body):
	if not self.collision_active or self.current_target_enemy != null:
		return
	
	if body is Bullet:
		body.queue_free()
		damage()
	

func _center_on_mouse():
	self.position = get_viewport().get_mouse_position()
	

func _on_DamageTimer_timeout():
	self.collision_active = true


func _on_PickArea_body_entered(body):
	if not self.dragging or not self.collision_active or self.current_target_enemy != null:
		return
		
	if body is Enemy:
		set_current_target_enemy(body)
		_center_on_mouse()


func _on_PickArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if not self.dragging and event.pressed and event.button_index == 1:
			self.dragging = true
			self.position = event.position
		elif not event.pressed:
			trail.emitting = false
