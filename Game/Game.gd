extends Node2D

signal bonus_activated(bonus_name)

export(PackedScene) var bg_effect_scene
export(PackedScene) var enemy_scene

onready var bg_effect_timer = $BgEffectSpawnTimer
onready var enemy_spawn_timer = $EnemySpawnTimer
onready var axis = $Axis
onready var focused_phrase_display = $FocusedPhraseBigDisplay
onready var bonus_anim = $BonusAnim
onready var score_label = $ScoreLabel

const EFFECT_SPAWN_Y := -100

var effect_spawn_delay := 0.3
var enemy_spawn_delay := 5
var max_enemies_alive := 2
var default_enemy_speed = 50
var enemies_alive := 0
var enemy_paused := false
var last_enemy_spawn_index := 0
var last_enemy_target_index := 0
var initial_axis_pos = Vector2(480, 460)
var bonus_activated = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$BgAnimator.play("Main")
	bg_effect_timer.start(effect_spawn_delay)
	enemy_spawn_timer.start(enemy_spawn_delay)
	axis.connect("focus_started", self, "_on_axis_focus_started")
	axis.connect("focus_ended", self, "_on_axis_focus_ended")
	axis.connect("letter_emitted", self, "_on_axis_letter_emitted")
	axis.connect("bonus_activated", self, "_on_bonus_activated")
	axis.connect("scored", self, "_on_axis_scored")
	
	focused_phrase_display.hide()
	
	_update_score_label()
	
	randomize()
	spawn_enemy()


func set_current_phrase(phrase):
	axis.set_current_phrase(phrase, Common.WordMode.Letters)


func return_from_bonus():
	self.axis.position = self.initial_axis_pos
	self.bonus_activated = false
	self.enemy_paused = false
	self.bonus_anim.reset()
	_update_score_label()

func spawn_enemy():
	
	var enemy = enemy_scene.instance()
	add_child(enemy)
	enemy.connect("died", self, "_on_enemy_died")
	enemy.set_text(WordGenerator.generate())
	enemy.position = _get_next_enemy_spawn_pos()
	enemy.set_target(_get_next_enemy_target_pos(), default_enemy_speed)
	enemy.set_axis(axis)
	
	enemies_alive += 1


func _get_next_enemy_spawn_pos():
	
	var index = randi() % 5 + 1
	
	while index == last_enemy_spawn_index:
		index = randi() % 5 + 1
	
	last_enemy_spawn_index = index
	
	return get_node("EnemySpawnPoint" + str(index)).position
	
	
func _get_next_enemy_target_pos():
	
	var index = randi() % 5 + 1
	
	while index == last_enemy_target_index:
		index = randi() % 5 + 1
	
	last_enemy_target_index = index
	
	return get_node("EnemyTargetPoint" + str(index)).position


func spawn_bg_effect():
	var x = rand_range(-100, get_viewport().size.x + 100)
	var bg_effect = bg_effect_scene.instance()
	add_child(bg_effect)
	bg_effect.position = Vector2(x, EFFECT_SPAWN_Y)


func _on_bg_effect_spawn_timeout():
	spawn_bg_effect()


func _on_enemy_died():
	enemies_alive -= 1


func _on_enemy_spawn_timeout():
	if self.bonus_activated:
		return
		
	if enemies_alive < max_enemies_alive:
		spawn_enemy()
	

func _on_EnemyActiveArea_body_entered(body):
	if body is Enemy:
		body.active = true


func _on_EnemyDestroyArea_body_exited(body):
	if body is Enemy and body.active:
		body.active = false
		body.queue_free()
		
		
func _on_axis_focus_started(phrase):
	
	enemy_paused = true
	
	var pos_y = 0
	
	if axis.position.y > get_viewport_rect().size.y/2:
		pos_y = 0
	else:
		pos_y = get_viewport_rect().size.y - focused_phrase_display.get_height()
	
	
	focused_phrase_display.position.y = pos_y
	
	focused_phrase_display.set_display(true)
	focused_phrase_display.set_phrase(phrase)


func _on_axis_focus_ended():
	if not self.bonus_activated:
		enemy_paused = false
	
	focused_phrase_display.set_display(false)


func _on_axis_letter_emitted(letter):
	focused_phrase_display.process_letter(letter)


func _on_axis_scored(value):
	PlayerData.player_score += value
	_update_score_label()

func _update_score_label():
	score_label.text = "SCORE: " + str(PlayerData.player_score)


func _on_bonus_activated(bonus_name):
	
	self.bonus_activated = true
	self.enemy_paused = true
	
	self.bonus_anim.start()
	yield(get_tree().create_timer(5),"timeout")
	
	emit_signal("bonus_activated", bonus_name)

