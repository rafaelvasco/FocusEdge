extends Node2D


func set_phrase(phrase):
	$TextLabel.set_text(phrase)
	

func get_height():
	return $ColorRect.get_rect().size.y


func set_display(show):
	if show:
		self.show()
		$AnimationPlayer.play("Appear")
	else:
		$AnimationPlayer.play("Disappear")
	



func process_letter(letter):
	$TextLabel.process_letter(letter)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Disappear":
		self.hide()
