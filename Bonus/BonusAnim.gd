extends Node2D


func reset():
	hide()
	$AnimationPlayerOneShot.stop()
	$AnimationPlayerLoop.stop()
	

func start():
	show()
	$AnimationPlayerOneShot.play("Main")
	$AnimationPlayerLoop.play("Main")
	
