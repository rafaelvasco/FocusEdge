class_name Enemy
extends KinematicBody2D

var scale_map = {
	5: 0.2,
	7: 0.5,
	10: 1.0
}

signal died

const bullet_scene = preload("res://Bullet.tscn")

onready var label = $WordBg/Word
onready var label_bg = $WordBg
onready var shoot_timer = $ShootTimer
onready var shoot_audio = $ShootAudio
onready var die_audio = $DieAudio
onready var hit_audio = $HitAudio

var word = ""
var mode = null
var target_point = Vector2.ZERO
var axis = null
var alive = true
var word_index = 0
var focused = false
var active = false

var speed = 100

func _ready():
	$AnimationPlayer.play("Main")
	shoot_timer.start(1.0)

func _process(delta):
	
	if alive :
		if not self.focused:
			var move_vector = (self.target_point - self.position).normalized()
			self.position += move_vector * speed * delta
		else:
			pass
	


func set_axis(axis):
	self.axis = axis


func set_target(position, speed):
	
	self.target_point = position
	self.speed = speed



func set_word(word, mode):
	
	self.word = word
	self.mode = mode
	match mode:
		Common.WordMode.Letters:
			self.label.text = word
			
		Common.WordMode.Colors:
			pass


func get_hit():
	
	if not self.focused:
		return
		
	self.word_index += 1
	_update_label()
	
	if self.word_index < self.word.length():
		hit_audio.set_pitch_scale(1.0 + (self.word_index/5))
		hit_audio.play()
		
	if self.word_index > self.word.length()-1:
		emit_signal("died")
		hide()
		die_audio.play()
		yield(get_tree().create_timer(1.0), "timeout")
		queue_free()


func shoot():
	var bullet = bullet_scene.instance()
	bullet.start(self.global_position, self.get_angle_to(self.axis.global_position))
	get_parent().add_child(bullet)
	shoot_audio.play()
	


func _update_label():
	self.label.text = self.word.substr(self.word_index)


func set_focused(focused):
	
	self.focused = focused
	if focused:
		$FocusOrb.show()	
		$AnimationPlayer.play("Focused")
	else:
		$FocusOrb.hide()
		$AnimationPlayer.play("Main")
		self.word_index = 0
		_update_label()
	

func _on_ShootTimer_timeout():
	if active:
		shoot()


func _exit_tree():
	emit_signal("died")

