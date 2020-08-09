extends Node2D

onready var text = $Text
onready var axis = $Axis
onready var progress_bar = $ProgressBar
onready var timer = $Timer
onready var score_anim = $BonusScoreDisplay

const TIME_MULTIPLIER = 50#0.85
const BONUS_SCORE = 100

var total_time = 0.0

const texts = [

"""I never see what has been done. I only see what remains to be done.""",
"""You only lose what you cling to.""",
"""The past is already gone, the future is not yet here. There's only one moment for you to live""",
"""As you walk and eat and travel, be where you are. Otherwise you will miss most of your life""",
"""Your work is to discover your work and then with all your heart to give yourself to it.""",
"""Believe nothing, no matter where you read it, or who said it, no matter if I have said it, unless it agress with your own reason and your own common sense.""",
"""Teach this triple truth to all: A generous heart, kind speech, and a life of service and compassion are the things which renew humanity.""",
"""What you think, you become. What you feel, you attract. What you imagine, you create."""
]


func _ready():
	text.connect("text_finished", self, "_on_text_finished")
	score_anim.connect("ended", self, "_on_bonus_score_anim_ended")
	

func setup():
	score_anim.hide()
	axis.clear_target()
	var random_text = _get_random_text()
	total_time = random_text.length() * TIME_MULTIPLIER
	
	text.set_text(random_text)
	axis.set_current_target_text(text)
	_run_timer(true)
	

func _on_text_finished():
	_run_timer(false)
	PlayerData.player_score += BONUS_SCORE
	score_anim.start(BONUS_SCORE)


func _run_timer(run: bool):
	if run:
		progress_bar.set_value(0)
		timer.start(total_time)
		set_process(true)
	else:
		progress_bar.set_value(0)
		timer.stop()
		set_process(false)


func _get_random_text():
	return texts[randi() % texts.size()]


func _return_to_game():
	$"/root/Main".return_to_game()
	

func _process(delta):
	
	var progress = (total_time - timer.time_left)/total_time
	progress_bar.set_value(progress)


func _on_Timer_timeout():
	_run_timer(false)
	_return_to_game()
	

func _on_bonus_score_anim_ended():
	_return_to_game()
	score_anim.reset()
	
