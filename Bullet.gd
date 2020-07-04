class_name Bullet
extends KinematicBody2D

var speed = 500
var velocity  = Vector2()

func start(pos, dir):
	self.rotation = dir
	self.position = pos
	self.velocity = Vector2(speed, 0).rotated(rotation)
	

func _physics_process(delta):
	move_and_collide(self.velocity * delta)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
