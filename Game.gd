extends Node2D

var bg_effect_scene = preload("res://BgEffect.tscn")
onready var bg_effect_timer = $BgEffectSpawnTimer
const EFFECT_SPAWN_Y = -100

var effect_spawn_delay = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	bg_effect_timer.start(effect_spawn_delay)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func spawn_bg_effect():
	var x = rand_range(-100, get_viewport().size.x + 100)
	var bg_effect = bg_effect_scene.instance()
	add_child(bg_effect)
	bg_effect.position = Vector2(x, EFFECT_SPAWN_Y)

func _on_bg_effect_spawn_timeout():
	spawn_bg_effect()
