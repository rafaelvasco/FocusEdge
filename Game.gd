extends Node2D

const bg_effect_scene = preload("res://BgEffect.tscn")
const enemy_scene = preload("res://Enemy.tscn")

onready var bg_effect_timer = $BgEffectSpawnTimer
onready var enemy_spawn_timer = $EnemySpawnTimer
onready var axis = $Axis

const EFFECT_SPAWN_Y := -100

var effect_spawn_delay := 3
var enemy_spawn_delay := 5
var max_enemies_alive := 5
var enemies_alive := 0

var last_enemy_spawn_index := 0
var last_enemy_target_index := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	bg_effect_timer.start(effect_spawn_delay)
	enemy_spawn_timer.start(enemy_spawn_delay)
	
	randomize()
	
	spawn_enemy()


func set_current_phrase(phrase):
	axis.set_current_phrase(phrase, Common.WordMode.Letters)
	

func spawn_enemy():
	
	var enemy = enemy_scene.instance()
	add_child(enemy)
	enemy.connect("died", self, "_on_enemy_died")
	enemy.set_word(Common.GetRandomLetterWord(4), Common.WordMode.Letters)
	enemy.position = _get_next_enemy_spawn_pos()
	enemy.set_target(_get_next_enemy_target_pos(), 25)
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
	if enemies_alive < max_enemies_alive:
		spawn_enemy()
	

func _on_EnemyActiveArea_body_entered(body):
	if body is Enemy:
		body.active = true


func _on_EnemyDestroyArea_body_exited(body):
	if body is Enemy and body.active:
		body.active = false
		body.queue_free()
		

