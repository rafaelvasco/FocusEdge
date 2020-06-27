extends Node2D

const bg_effect_scene = preload("res://BgEffect.tscn")
const enemy_scene = preload("res://Enemy.tscn")


onready var bg_effect_timer = $BgEffectSpawnTimer
onready var enemy_spawn_timer = $EnemySpawnTimer
onready var axis = $Axis


const EFFECT_SPAWN_Y = -100

var effect_spawn_delay = 5
var enemy_spawn_delay = 5

var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	axis.connect("symbol_emitted", self, "_on_axis_symbol_emitted")
	
	bg_effect_timer.start(effect_spawn_delay)
	enemy_spawn_timer.start(enemy_spawn_delay)
	
	randomize()
	
	spawn_enemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_current_phrase(phrase):
	axis.set_current_phrase(phrase, Common.WordMode.Letters)
	


func spawn_enemy():
	
	var enemy = enemy_scene.instance()
	add_child(enemy)
	enemy.set_word(Common.GetRandomLetterWord(4), Common.WordMode.Letters)
	
	var enemy_src_pos = Vector2(rand_range(0, get_viewport_rect().size.x), - 100)
	var enemy_target_pos = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.x + 100)
	
	enemy.position = enemy_src_pos
	enemy.direction = Common.Directions.LEFT
	enemy.set_target(enemy_target_pos, 25)
	enemies.push_back(enemy)


func spawn_bg_effect():
	var x = rand_range(-100, get_viewport().size.x + 100)
	var bg_effect = bg_effect_scene.instance()
	add_child(bg_effect)
	bg_effect.position = Vector2(x, EFFECT_SPAWN_Y)


func _on_axis_symbol_emitted(symbol, direction):
	
	if axis.current_target_word == null:
		self._allocate_target_for_axis(symbol, direction)



func _shoot_bullet():
	pass



func _allocate_target_for_axis(symbol, direction):
	
	for enemy in enemies:
		if enemy.word[0] == symbol:
			axis.set_current_target_word(enemy)
			break
	

func _on_bg_effect_spawn_timeout():
	spawn_bg_effect()



func _on_enemy_spawn_timeout():
	spawn_enemy()
	
	
