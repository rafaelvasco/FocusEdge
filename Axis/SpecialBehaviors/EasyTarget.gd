extends Behavior

var last_target_direction = null

func on_activated(axis, target_direction):
	if self.last_target_direction != null:
		_mark_target_axis(axis, self.last_target_direction, false)
	_mark_target_axis(axis, target_direction, true)

func on_deactivated(axis):
	if self.last_target_direction != null:
		_mark_target_axis(axis, last_target_direction, false)
		
	last_target_direction = null

func get_total_time():
	return 5

func _mark_target_axis(axis, direction, mark):
	if mark:
		self.last_target_direction = direction
		
	axis.mark_target_axis(direction, mark)
