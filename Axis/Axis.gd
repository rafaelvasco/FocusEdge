extends Node2D

var EasyTarget = load("res://Axis/SpecialBehaviors/EasyTarget.gd")

onready var buttons = $AxisButtons
onready var bullet_spawn_origin = $BulletSpawnOrigin
onready var damage_timer = $DamageTimer
onready var focus_timer = $FocusTimer
onready var behavior_timer = $BehaviorTimer
onready var power_up_aura = $PowerUpAura
onready var damage_audio = $DamageAudio
onready var tween = $Tween
onready var trail = $Trail
onready var focus_timer_circle = $FocusTimerCircle


export(PackedScene) var press_effect

const ANIMATE_GROW_TIME = 0.25
const BASE_SCALE = 0.25
const BASE_SCORE_ANIM_SCALE = 3
const TARGET_SCORE_ANIM_SCALE = 1.0
const TIME_OUT_DAMAGE = 2
const MAX_LIFE := 100.0

export var bonus_mode: bool = false

signal scored(value)
signal focus_started(phrase)
signal focus_ended
signal letter_emitted(letter)
signal camera_shake_requested
signal bonus_activated(bonus_name)

var life = MAX_LIFE
var current_target_enemy = null
var current_target_text = null
var mouse_down := false
var choosing_symbol := false
var last_generated_target_direction = null
var collision_active := true
var last_position = Vector2.ZERO
var initial_position = Vector2.ZERO
var last_triggered_direction = null
var special_behaviors = {
	Common.SpecialAxisBeahaviors.EasyTarget : EasyTarget.new()
}
var current_special_behavior: Behavior = null
var special_behavior_end_requested = false

func _ready():
	initial_position = self.position
	scale = Vector2(BASE_SCALE, BASE_SCALE)
	$Trail.process_material.scale = BASE_SCALE
	$AnimationPlayer.stop()
	$AnimationPlayer.get_animation("Score").track_set_key_value(0, 0, BASE_SCORE_ANIM_SCALE)
	_set_default_body_color()
	_show_axis_directions_bg(false)
	focus_timer_circle.hide()
	clear_target()
	trail.emitting = false
	randomize()
	set_process(false)


func _process(_delta):
	
	if self.current_target_enemy == null:
		return
	
	var current_focus_total_time = self.current_target_enemy.get_total_focus_time()
	var current_focus_perc_value = ((current_focus_total_time - focus_timer.get_time_left())/current_focus_total_time) * 100
	self.focus_timer_circle.material.set_shader_param("value", current_focus_perc_value)	
		

func set_current_target_enemy(enemy):
	
	self.current_target_enemy = enemy
	self.current_target_enemy.set_focused(true)
	self.choosing_symbol = true
	
	if self.current_special_behavior:
		behavior_timer.paused = true
		
	populate_axis_elements()
	update_visuals()
	start_focus_timer()
	emit_signal("focus_started", self.current_target_enemy.get_phrase().get_text_str())


func set_current_target_text(text):
	self.current_target_text = text
	

func start_focus_timer():
	
	focus_timer.start(self.current_target_enemy.get_total_focus_time())
	set_process(true)
	focus_timer_circle.show()
	

func stop_focus_timer():
	focus_timer.stop()
	set_process(false)


func activate_special_behavior(behavior):
	self.current_special_behavior = self.special_behaviors[behavior]
	behavior_timer.start(self.current_special_behavior.get_total_time())
	

func remove_special_behavior():
	_set_default_body_color()
	self.current_special_behavior.on_deactivated(self)
	self.current_special_behavior = null


func clear_target():
	
	if self.current_special_behavior:
		behavior_timer.paused = false
		self.current_special_behavior.on_deactivated(self)
	
	if self.current_target_enemy != null:
		self.current_target_enemy.set_focused(false)
	elif self.current_target_text != null:
		self.current_target_text.reset()
		
	self.current_target_enemy = null
	self.choosing_symbol = false
	
	self.last_generated_target_direction = null
		
	stop_focus_timer()
	self.update_visuals()
	
	if not self.bonus_mode:
		_center_on_mouse()
	else:
		self.position = self.initial_position
	
	if not self.bonus_mode:
		emit_signal("focus_ended")


func update_visuals():
	
	if self.choosing_symbol:
		_show_axis_directions_bg(true)
		_animate_to_scale(TARGET_SCORE_ANIM_SCALE)
		$FocusAnimationPlayer.play("Main")	
		for btn in buttons.get_children():
			btn.get_node("Letters").show()
	else:
		_show_axis_directions_bg(false)
		$FocusAnimationPlayer.stop()
		focus_timer_circle.hide()
		_animate_to_scale(BASE_SCALE)
		for btn in buttons.get_children():
			btn.get_node("Letters").hide()


func _animate_to_scale(target: float):
	if self.scale.x == target:
		return
		
	tween.remove_all()		
	tween.interpolate_property(self, "scale", self.scale, Vector2(target, target), ANIMATE_GROW_TIME)
	tween.connect("tween_completed", self, "_on_tween_scale_completed")
	tween.start()
	

func populate_axis_elements():
	
	var target_direction = Common.GetRandomDirection()
	
	if self.last_generated_target_direction != null:
		while target_direction == self.last_generated_target_direction:
			target_direction = Common.GetRandomDirection()
	else:
		while target_direction == self.last_triggered_direction:
			target_direction = Common.GetRandomDirection()
		
	self.last_generated_target_direction = target_direction
	
	if self.current_special_behavior:
		self.current_special_behavior.on_activated(self, target_direction)
	
	var current_target_letter = null

	if self.current_target_enemy != null:
		current_target_letter = self.current_target_enemy.get_phrase().get_current_target_letter()
	elif self.current_target_text != null:
		current_target_letter = self.current_target_text.get_current_target_letter()
	else:
		return
	
	var generated_letters = []
	
	generated_letters.append(current_target_letter)
	
	var random_placeholder_letter = null
	
	match target_direction:
		Common.Directions.Left: 
			_set_letter("Left", current_target_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Right", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Up", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Down", random_placeholder_letter)
			
		Common.Directions.Right: 
			_set_letter("Right", current_target_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Left", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Up", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Down", random_placeholder_letter)
			
		Common.Directions.Up: 
			_set_letter("Up", current_target_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Right", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Left", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Down", random_placeholder_letter)
			
		Common.Directions.Down: 
			_set_letter("Down", current_target_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Right", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Up", random_placeholder_letter)
			generated_letters.append(random_placeholder_letter)
			
			random_placeholder_letter = _get_random_letter(generated_letters)
			_set_letter("Left", random_placeholder_letter)


func mark_target_axis(direction, mark):
	var direction_str = Common.Directions.keys()[direction]
	if mark:
		buttons.get_node(direction_str).get_node("SymbolBg").self_modulate = Color(0, 1, 0, 0.5)
	else:
		buttons.get_node(direction_str).get_node("SymbolBg").self_modulate = Color(0, 0, 0, 0.5)


func _get_letter(axis):
	var symbol = buttons.get_node(axis + "/Letters/Label").text
	return symbol


func _set_letter(axis, letter):
	
	var target = buttons.get_node(axis + "/Letters/Label")
	
	if letter != " ":
		target.text = letter
	else:
		target.text = "_"


func _get_random_letter(generated_letters):
	
	var random_letter = Common.GetRandomDigit()
	var clashes = 1
	
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
		
	if self.last_triggered_direction == direction:
		return
	
	var direction_str = Common.Directions.keys()[direction]
	spawn_axis_effect(direction_str)
	trigger_letter(direction_str)


func trigger_letter(direction):
	var chosen_symbol = _get_letter(direction)
	
	if not self.choosing_symbol:
		return
		
	var result = null
	
	if self.current_target_enemy != null:
		result = self.current_target_enemy.process_symbol(chosen_symbol)
	elif self.current_target_text != null:
		result = self.current_target_text.process_letter(chosen_symbol)
	else:
		return
	
	emit_signal("letter_emitted", chosen_symbol)
		
	_process_target_text_result(result)


func _process_target_text_result(result):
	if result != null:
		var check = result[0]
		var text_finished = result[1]
		
		if check:
			if not text_finished:
				populate_axis_elements()
			else:
				
				var bonus_activated = null
				var special_behavior_activated = null
				
				if self.current_target_enemy != null:
					bonus_activated  = self.current_target_enemy.bonus_when_killed
					special_behavior_activated = self.current_target_enemy.prize_when_killed
				
				if bonus_activated:
					self.mouse_down = false
				
				if bonus_activated != null:
					emit_signal("bonus_activated", bonus_activated)
				elif special_behavior_activated != null:
					self.activate_special_behavior(special_behavior_activated)
				
				score()
				clear_target()
		else:
			if not self.bonus_mode:
				damage(self.current_target_enemy.get_damage())
			else:
				damage(0)
					
func spawn_axis_effect(direction):
	var axis_element = buttons.get_node(direction)
	var spawn_effect_pos = axis_element.get_node("SpawnPoint").position
	var effect = press_effect.instance()
	axis_element.add_child(effect)
	effect.position = spawn_effect_pos
	

func damage(value):
	print("Damage")
	self.life -= value
	
	if self.life <= 0:
		self.life = 0
		self.die()
	
	$AnimationPlayer.play("Damage")
	
	damage_timer.start(1)
	self.collision_active = false
	emit_signal("camera_shake_requested")
	damage_audio.play()
	
	
func die():
	get_tree().reload_current_scene()


func score():
	power_up_aura.show()
	$AnimationPlayer.play("Score")
	damage_timer.start(1)
		
	self.collision_active = false
	
	if not self.bonus_mode:
		emit_signal("scored", int(self.current_target_enemy.get_kill_score()))


func _input(event):
	
	if event is InputEventMouseButton:
		if not event.pressed and self.mouse_down:
			self.mouse_down = false
			self.choosing_symbol = false
			self.clear_target()	
				
	elif event is InputEventMouseMotion:
		if not self.mouse_down:
			return
		
		if not self.choosing_symbol and not self.bonus_mode:
				
			self.position += event.get_relative()
			
			if self.position.distance_to(self.last_position) > 0:
				trail.emitting = true
			else:
				trail.emitting = false
			
			self.last_position = self.position


func _on_mouse_enter_left_axis():
	if not self.choosing_symbol or tween.is_active():
		return
		
	trigger_axis(Common.Directions.Left)
	self.last_triggered_direction = Common.Directions.Left


func _on_mouse_enter_right_axis():
	if not self.choosing_symbol or tween.is_active():
		return
	
	trigger_axis(Common.Directions.Right)
	self.last_triggered_direction = Common.Directions.Right


func _on_mouse_enter_up_axis():
	if not self.choosing_symbol or tween.is_active():
		return
	
	trigger_axis(Common.Directions.Up)
	self.last_triggered_direction = Common.Directions.Up


func _on_mouse_enter_down_axis():
	if not self.choosing_symbol or tween.is_active():
		return
	
	trigger_axis(Common.Directions.Down)
	self.last_triggered_direction = Common.Directions.Down


func _on_CollisionArea_body_entered(body):
	if $"/root/Main/Game".enemy_paused:
		return
	
	if not self.collision_active or self.current_target_enemy != null:
		return
	
	if body is Bullet:
		body.queue_free()
		damage(body.damage)
	

func _center_on_mouse():
	self.position = get_viewport().get_mouse_position()



func _show_axis_directions_bg(show):
	if show:
		$AxisButtons/Up/SymbolBg.show()
		$AxisButtons/Down/SymbolBg.show()
		$AxisButtons/Left/SymbolBg.show()
		$AxisButtons/Right/SymbolBg.show()
	else:
		$AxisButtons/Up/SymbolBg.hide()
		$AxisButtons/Down/SymbolBg.hide()
		$AxisButtons/Left/SymbolBg.hide()
		$AxisButtons/Right/SymbolBg.hide()


func _on_DamageTimer_timeout():
	self.collision_active = true
	if self.current_special_behavior != null:
		_set_body_color("#64ffbf00")
	else:
		_set_default_body_color()
	$AnimationPlayer.stop()


func _set_default_body_color():
	print("Default Color")
	$Circle.self_modulate = "#6400e7ff"


func _set_body_color(color):
	$Circle.self_modulate = color


func _on_PickArea_body_entered(body):
	
	if $"/root/Main/Game".enemy_paused:
		return
	
	if not self.mouse_down or not self.collision_active or self.current_target_enemy != null:
		return
		
	if body is Enemy:
		set_current_target_enemy(body)
		_center_on_mouse()


func _on_PickArea_input_event(_viewport, event, _shape_idx):
	
	if not self.bonus_mode and $"/root/Main/Game".enemy_paused:
		return
		
	if event is InputEventMouseButton:
		if not self.mouse_down and event.pressed and event.button_index == 1:
			self.mouse_down = true
			if not self.bonus_mode:
				self.position = event.position
			else:
				self.choosing_symbol = true
				populate_axis_elements()
				update_visuals()
				
		elif not event.pressed:
			trail.emitting = false


func _on_FocusTimer_timeout():
	clear_target()
	damage(TIME_OUT_DAMAGE)


func _on_BehaviorTimer_timeout():
	remove_special_behavior()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Damage":
		if self.current_special_behavior != null:
			_set_body_color("#64ffbf00")
		else:
			_set_default_body_color()
