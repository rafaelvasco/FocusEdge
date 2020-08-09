extends RichTextLabel

signal text_finished()

class TextWord:
	var string := ""
	var index := 0
	
	func is_empty():
		return string.empty()
	
	func check_letter(ch):
		var _match = self.string[index].to_lower() == ch.to_lower()
		return _match
	
	func get_current_target_letter():
		return self.string[self.index].to_lower()
	
	func get_current_substring():
		return self.string.substr(self.index)
	
	func reset():
		self.index = 0
	
	func length():
		return self.string.length()


onready var hit_audio = $HitAudio

var text_str = ""
var line_array = []
var lines_word_indices = []
var line_index = 0
var word_index = 0
var unique_letters = []
var _total_letter_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_blinking(true)


func set_text(text: String):
	
	if not text or text.length() == 0:
		return
	
	self.line_index = 0
	self.text_str = text
	self.lines_word_indices = []
	self.line_array = []
	self.unique_letters = []
	
	# Split text into lines
	var lines = self.text_str.split("\n")
	
	for line in lines:
		if line.length() > 0:
			# Split line into words by space
			var words = line.split(" ")
			var word_array = []
			self._total_letter_count = 0
			
			for word in words:
				self._total_letter_count += word.length()
				var text_word = TextWord.new()
				text_word.string = word
				text_word.index = 0
				word_array.append(text_word)
			
			self.line_array.append(word_array)
			self.lines_word_indices.append(0)
		else:
			# If line is blank add empty word
			self.line_array.append([])
			self.lines_word_indices.append(0)
	
	_update_label()	
	

func get_current_target_letter():
	return self.line_array[self.line_index][self.lines_word_indices[self.line_index]].get_current_target_letter()


func get_total_letter_count():
	return self._total_letter_count
	

func get_text_str():
	return self.text_str


func reset():
	self.line_index = 0
	for index in range(self.lines_word_indices.size()):
		self.lines_word_indices[index] = 0
		
	for line in self.line_array:
		for word in line:
			word.reset()
	
	_update_label()


func process_letter(letter):
	var current_word: TextWord = self.line_array[self.line_index][self.lines_word_indices[self.line_index]]
	var check = current_word.check_letter(letter)
	var text_finished = false
	if check:
		current_word.index += 1
		# If reached end of current word go to next word
		if current_word.index > current_word.length()-1:
			if self.lines_word_indices[self.line_index] < self.line_array[self.line_index].size()-1:
				self.lines_word_indices[self.line_index] += 1
			
			# If reached end of last word of line go to next line
			else:
				# If still have lines to go
				if line_index < self.line_array.size() - 1:
					line_index += 1
					# If found blank line keep going
					while line_index < (self.line_array.size() - 1) and self.line_array[self.line_index].empty():
						line_index += 1
				# If no more lines to go, text is finished			
				else:
					emit_signal("text_finished")
					text_finished = true
		
		if not text_finished:
			self.hit_audio.play()	
				
	
	_update_label()
	return [check, text_finished]
	

func _update_label():
	
	var new_text = ""
	
	# For each line starting from line_index to end
	for _line_index in range(self.line_index, self.line_array.size()):
		# For each word in line starting from word index from that line to end:
		for _word_index in range(self.lines_word_indices[_line_index], self.line_array[_line_index].size()):
			var word = self.line_array[_line_index][_word_index]
			# Get current substring from word defined by its internal index
			new_text += word.get_current_substring()
			
			# If its not the last word from current line separate word with space
			if _word_index < self.line_array[_line_index].size()-1:
				new_text += " "
				
		# At the end of each line add line break
		new_text += "\n"
	
	bbcode_text = "[center]" + new_text + "[/center]"


func set_blinking(blinking: bool):
	if blinking:
		$AnimationPlayer.play("Blink")
	else:
		$AnimationPlayer.play("Default")
