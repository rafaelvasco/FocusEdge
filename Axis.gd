extends Node2D

export var Modes = {
	Colors = "Colors",
	Letters = "Letters"
};

var mode = Modes.Letters

onready var buttons = $CanvasLayer/Control/AxisButtons
var press_effect = preload("res://AxisEffect.tscn")

signal axis_pressed(direction)

func _ready():
	pass



func set_mode(mode):
	self.mode = mode
	
	if mode == Modes.Letters:
		for btn in buttons.get_children():
			btn.get_node("Letters").show()
			btn.get_node("Colors").hide()
	elif mode == Modes.Colors:
		for btn in buttons.get_children():
			btn.get_node("Letters").hide()
			btn.get_node("Colors").show()



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
	print("Trigger " + direction)
	var axis_element = buttons.get_node(direction)
	var spawn_effect_pos = axis_element.get_node("SpawnPoint").position
	var effect = press_effect.instance()
	axis_element.add_child(effect)
	effect.position = spawn_effect_pos
	emit_signal("axis_pressed", direction)


func _process(delta):
	pass
	
