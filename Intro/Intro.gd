extends Control

var _circle_offset = 0
var _circle_offset_anim_speed = 100

onready var start_label = $Circle/StartLabel

func _ready():
	$AnimationPlayer.play("Main")
	$BackTitleAnimationPlayer.play("Main")
	$Circle.material.set_shader_param("value", 100)

func _process(delta):
	_animate_circle(delta)
	

func _animate_circle(delta):
	
	var material = $Circle.material
	
	_circle_offset += _circle_offset_anim_speed * delta
	
	if _circle_offset > 100:
		_circle_offset = 0
	
	material.set_shader_param("offset", _circle_offset)


func _on_play_input_event(event):
	if event is InputEventMouseButton:
		if event.pressed:
			start_label.rect_position.y = 74
		else:
			start_label.rect_position.y = 70
			get_tree().change_scene("res://Main.tscn")
		
