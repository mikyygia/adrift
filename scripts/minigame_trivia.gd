extends Control

signal trivia_won
signal trivia_lost

# ---------------------------------------------------------------------------
# Questions data
# ---------------------------------------------------------------------------
var questions = [
	{
		"fish_text": "First one's easy. You should get this. What's the only mammal that can actually fly?",
		"answers": ["A bat", "A flying squirrel", "A sugar glider", "A lemur"],
		"correct": 0,
		"wrong_response": "It's kinda basic, you should know that. It's okay, try again."
	},
	{
		"fish_text": "Hehe, I'm giving you this one for warming up. At a famous university, what is the mascot?",
		"answers": ["Peter Dwyane Johnson", "Robert the Anteater", "Peter the Anteater", "Mr. Fresh the First"],
		"correct": 2,
		"wrong_response": "Do you even attend school? That is common knowledge. It's okay, try again."
	},
	{
		"fish_text": "This one's from a book I read about game production. Good designers don't just trust themselves — they watch other people play instead?",
		"answers": ["Play testing", "Speedrunning", "Debugging", "Rendering"],
		"correct": 0,
		"wrong_response": "No, you are not even thinking about the question. It's okay, try again."
	},
	{
		"fish_text": "This one's fun. Even my tutor got this wrong once. Which of these is actually a Pokémon name?",
		"answers": ["Sentret", "Loratadine", "Clopidogrel", "Metformin"],
		"correct": 0,
		"wrong_response": "Someone probably doesn't have a childhood. It's okay, try again."
	},
	{
		"fish_text": "Bingo! Final question. Which of these is NOT the official name of a country?",
		"answers": [
			"United Kingdom of Great Britain and Southern Ireland",
			"Federative Republic of Brazil",
			"People's Republic of China",
			"Kingdom of the Netherlands"
		],
		"correct": 0,
		"wrong_response": "I guess you never travel a lot? It's okay, not everyone is privileged enough. Try again."
	}
]

var current_question: int = 0
var chances: int = 3
var current_wrong_attempts: int = 0  # wrong attempts on current question

# ---------------------------------------------------------------------------
# Node refs — we build the UI in code so you don't need to set up the scene manually
# ---------------------------------------------------------------------------
var fish_portrait: TextureRect
var fish_dialogue_box: Panel
var fish_dialogue_label: Label
var question_label: Label
var answers_container: VBoxContainer
var chances_label: Label
var fish_speaking: bool = false

func _ready() -> void:
	_build_ui()
	_show_intro()

# ---------------------------------------------------------------------------
# Build the UI entirely in code
# ---------------------------------------------------------------------------
func _build_ui() -> void:
	# full screen background dim
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	# fish portrait — top right corner
	fish_portrait = TextureRect.new()
	fish_portrait.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	fish_portrait.position = Vector2(-180, 20)
	fish_portrait.size = Vector2(150, 150)
	fish_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	add_child(fish_portrait)

	# load kid fish portrait if available
	if GameState.currentFish and GameState.currentFish.portraits.has("default"):
		fish_portrait.texture = GameState.currentFish.portraits["default"]

	# fish dialogue box — top area
	fish_dialogue_box = Panel.new()
	fish_dialogue_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	fish_dialogue_box.position = Vector2(20, 20)
	fish_dialogue_box.size = Vector2(460, 90)
	fish_dialogue_box.visible = false
	add_child(fish_dialogue_box)

	fish_dialogue_label = Label.new()
	fish_dialogue_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	fish_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fish_dialogue_label.add_theme_font_size_override("font_size", 13)
	fish_dialogue_label.position = Vector2(10, 10)
	fish_dialogue_label.size = Vector2(440, 70)
	fish_dialogue_box.add_child(fish_dialogue_label)

	# chances label — top center
	chances_label = Label.new()
	chances_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	chances_label.position = Vector2(0, 120)
	chances_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chances_label.add_theme_font_size_override("font_size", 14)
	chances_label.text = "Chances: ♥ ♥ ♥"
	add_child(chances_label)

	# question label — middle of screen
	question_label = Label.new()
	question_label.set_anchors_preset(Control.PRESET_CENTER)
	question_label.position = Vector2(-300, -80)
	question_label.size = Vector2(600, 80)
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_label.add_theme_font_size_override("font_size", 15)
	add_child(question_label)

	# answer buttons — lower half
	answers_container = VBoxContainer.new()
	answers_container.set_anchors_preset(Control.PRESET_CENTER)
	answers_container.position = Vector2(-200, 20)
	answers_container.size = Vector2(400, 200)
	add_child(answers_container)

# ---------------------------------------------------------------------------
# Intro — fish warns about 3 chances
# ---------------------------------------------------------------------------
func _show_intro() -> void:
	_show_fish_dialogue("Okay. Before we start — you only get 3 chances total. Don't waste them. Ready?", true)

func _on_intro_done() -> void:
	_load_question(0)

# ---------------------------------------------------------------------------
# Load a question
# ---------------------------------------------------------------------------
func _load_question(index: int) -> void:
	current_wrong_attempts = 0
	var q = questions[index]

	# show fish asking the question
	_show_fish_dialogue(q["fish_text"], false)

	# update question label
	question_label.text = "Question " + str(index + 1) + " of " + str(questions.size())

	# clear old buttons
	for child in answers_container.get_children():
		child.queue_free()

	# build answer buttons
	for i in range(q["answers"].size()):
		var btn = Button.new()
		btn.text = q["answers"][i]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx = i
		btn.pressed.connect(func(): _on_answer_pressed(idx))
		answers_container.add_child(btn)

# ---------------------------------------------------------------------------
# Answer pressed
# ---------------------------------------------------------------------------
func _on_answer_pressed(index: int) -> void:
	var q = questions[current_question]

	if index == q["correct"]:
		# correct!
		_show_fish_dialogue("Hehe! That's right. Okay, next one.", false)
		_disable_buttons()
		await get_tree().create_timer(2.0).timeout
		current_question += 1

		if current_question >= questions.size():
			# all questions done — win!
			await get_tree().create_timer(0.5).timeout
			emit_signal("trivia_won")
		else:
			_load_question(current_question)
	else:
		# wrong
		chances -= 1
		_update_chances_display()
		_show_fish_dialogue(q["wrong_response"], false)

		if chances <= 0:
			_disable_buttons()
			await get_tree().create_timer(2.0).timeout
			emit_signal("trivia_lost")
		# if chances remain, buttons stay active — player tries again same question

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _show_fish_dialogue(text: String, is_intro: bool) -> void:
	fish_dialogue_box.visible = true
	fish_dialogue_label.text = text

	if is_intro:
		await get_tree().create_timer(3.0).timeout
		fish_dialogue_box.visible = false
		_on_intro_done()

func _disable_buttons() -> void:
	for btn in answers_container.get_children():
		btn.disabled = true

func _update_chances_display() -> void:
	var hearts = ""
	for i in range(chances):
		hearts += "♥ "
	for i in range(3 - chances):
		hearts += "♡ "
	chances_label.text = "Chances: " + hearts.strip_edges()

# Called when the node enters the scene tree for the first time.
