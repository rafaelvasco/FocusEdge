extends Sprite

func _ready():
	$AnimationPlayer.play("Main")


func _on_anim_finished(anim_name):
	if anim_name == "Main":
		queue_free()
