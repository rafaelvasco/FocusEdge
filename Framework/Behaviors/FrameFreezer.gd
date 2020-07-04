extends Node

export var delay_mseconds := 15

export var enabled := false

func _ready():
	for frame_freezer in get_tree().get_nodes_in_group("frame_freezers"):
		frame_freezer.connect("frame_freeze_requested", self, "_on_frame_freeze_requested")
		
		
func _on_frame_freeze_requested():
	if not self.enabled:
		return
	OS.delay_msec(self.delay_mseconds)

