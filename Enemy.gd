extends Sprite

var scale_map = {
	5: 0.2,
	7: 0.5,
	10: 1.0
}

onready var label = $WordBg/Word
onready var label_bg = $WordBg

var word = ""
var mode = null
var target_point = Vector2.ZERO
var alive = true

var speed = 100

func _ready():
	pass
	

func _process(delta):
	if alive:
		var move_vector = (self.target_point - self.position).normalized()
		self.position += move_vector * speed * delta
	


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
	
