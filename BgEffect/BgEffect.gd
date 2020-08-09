extends Sprite

var current_destination = Vector2.ZERO

const DESTINATION_THRESHOLD = 10

var life = 10
var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_random_destination()
	$AnimationPlayer.play("Main")



func set_random_destination():
	var view_w = get_viewport().size.x
	var view_h = get_viewport().size.y
	current_destination = Vector2(rand_range(0, view_w), rand_range(0, view_h))
	


func die():
	self.alive = false
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", self.modulate.a, 0.0, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()



func _process(delta):
	if position.distance_to(current_destination) > DESTINATION_THRESHOLD:
		self.position = self.position.linear_interpolate(current_destination, delta * 0.1)
	else:
		set_random_destination()
	
	self.life -= delta
	
	if self.alive and self.life <= 0:
		self.die()
