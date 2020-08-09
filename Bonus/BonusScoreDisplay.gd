extends Node2D

signal ended

onready var timer = $Timer
onready var score_label = $ColorRect/VBoxContainer/ScoreLabel

export var duration_seconds = 3.5

func reset():
	hide()
	timer.stop()
	$MainAnimation.stop()
	$AppearAnimation.stop()
	

func start(score):
	score_label.text = str(score)
	show()
	timer.start(duration_seconds)
	$AppearAnimation.play("Appear")
	$MainAnimation.play("Main")
	
	


func _on_Timer_timeout():
	emit_signal("ended")
