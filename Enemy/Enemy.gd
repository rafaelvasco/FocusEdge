class_name Enemy
extends KinematicBody2D

var scale_map = {
	5: 0.2,
	7: 0.5,
	10: 1.0
}

signal died

export(PackedScene) var bullet_scene

onready var label_bg = $WordBg
onready var target_phrase = $WordBg/TargetPhrase
onready var shoot_timer = $ShootTimer
onready var shoot_audio = $ShootAudio
onready var die_audio = $DieAudio


var target_point = Vector2.ZERO
var axis = null
var alive = true
var focused = false
var active = false
var focus_time_per_letter = 0.8
var bonus_when_killed = "BonusSceneOne"
var prize_when_killed = null#Common.SpecialAxisBeahaviors.EasyTarget
var base_damage = 20
var score_multiplier = 0.7

var speed = 0

func _ready():

	$AnimationPlayer.play("Main")
	shoot_timer.start(1.0)
	target_phrase.connect("text_finished", self, "_on_target_text_finished")
	randomize_bonus_prize()

func _process(delta):
	
	if $"/root/Main/Game".enemy_paused:
		return
	
	if alive :
		if not self.focused:
			var move_vector = (self.target_point - self.position).normalized()
			self.position += move_vector * speed * delta
		else:
			pass


func randomize_bonus_prize():
	var rand_chance = randi() % 10
	
	if rand_chance > 8:
		self.bonus_when_killed = "BonusSceneOne"	
	elif rand_chance > 6:
		self.prize_when_killed = Common.SpecialAxisBeahaviors.EasyTarget
		
	self.bonus_when_killed = "BonusSceneOne"	



func set_axis(value):
	self.axis = value


func set_target(position, _speed):
	self.target_point = position
	self.speed = _speed


func set_text(word):
	target_phrase.set_text(word)


func get_phrase():
	return target_phrase


func get_damage():
	return base_damage/self.target_phrase.get_total_letter_count()


func get_kill_score():
	return self.target_phrase.get_total_letter_count() * self.score_multiplier


func get_total_focus_time():
	return self.target_phrase.get_total_letter_count() * self.focus_time_per_letter


func process_symbol(symbol):
	if not self.focused:
		return null
	
	return self.target_phrase.process_letter(symbol)


func shoot():
	var bullet = bullet_scene.instance()
	bullet.start(self.global_position, self.get_angle_to(self.axis.global_position))
	get_parent().add_child(bullet)
	shoot_audio.play()
	


func set_focused(value):
	
	self.focused = value
	if self.focused:
		$FocusOrb.show()	
		$AnimationPlayer.play("Focused")
	else:
		$FocusOrb.hide()
		$AnimationPlayer.play("Main")
		self.target_phrase.reset()
	

func _on_ShootTimer_timeout():
	
	if $"/root/Main/Game".enemy_paused:
		return
	
	if alive and active and not focused:
		shoot()


func _on_target_text_finished():
	self.alive = false
	hide()
	die_audio.play()
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()


func _exit_tree():
	emit_signal("died")
