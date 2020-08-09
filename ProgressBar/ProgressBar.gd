extends Control


export(float) var progress_value setget set_value, get_value
export(int) var bar_height := 10 setget set_bar_height, get_bar_height
export(float) var blink_threshold := 0.7
export(Color) var base_color
export(Color) var target_color

var _max_width := 0
var _blinking := false
var _blink_control = false


onready var color_rect: ColorRect = $ColorRect
onready var blink_timer: Timer = $BlinkTimer

func _ready():
	self._max_width = 960
	color_rect.self_modulate = base_color
	self._update_visuals()
	

func set_value(value: float):
	progress_value = value
	_update_visuals()
	

func get_value() -> float:
	return progress_value


func set_bar_height(value: int):
	bar_height = value
	_update_visuals()
	

func get_bar_height() -> int:
	return bar_height


func _update_visuals():
	if color_rect:
		color_rect.set_size(Vector2(self._max_width * self.progress_value, bar_height))
		
		if self.progress_value < blink_threshold:
			color_rect.self_modulate = lerp(base_color, target_color, progress_value)
		else:
			if not self._blinking:
				self.blink_timer.start(0.05)
				self._blinking = true


func _on_BlinkTimer_timeout():
	if self._blink_control:
		color_rect.self_modulate = Color(1, 1, 1)
	else:
		color_rect.self_modulate = Color(1, 0, 0)
		
	self._blink_control = !self._blink_control
