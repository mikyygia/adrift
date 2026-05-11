# waiting_lady_minigame.gd
extends Node2D

signal minigame_finished(outcome: String)

@onready var cake_spawner = $CakeSpawner
@onready var present_spawner = $PresentSpawner
@onready var heart1 = $HBoxContainer/Hearts
@onready var heart2 = $HBoxContainer/Hearts2

# hook these up to your actual UI nodes
@onready var lady_overlay = $UiOverlay
@onready var dialogue_label = $UiOverlay/DialogueLabel  # adjust path to match your scene

# states
@onready var tutorial_panel = $TutorialPanel;
@onready var proceed_button = $TutorialPanel/Proceed;

var lives: int = 2
var current_stage: int = 1

const STAGE_DIALOGUE = {
	1: "You know, perhaps it would be easier if you simply stayed. My dolls would be so happy to have a new friend.",
	2: "What is so wrong with that? What is so wrong with me?",
}

const WIN_DIALOGUE = "I... I'm sorry. I shouldn't have. I just... I only ever wanted a friend."

func _ready() -> void:
	# before the game begins, there should be a screen that prompt users to click a button before proceeding
	# show movement
	# show how to win
	# show how to die
	
	# !! always connect signals first regardless of start screen
	cake_spawner.cake_hit_player.connect(_on_cake_hit)
	present_spawner.all_collected.connect(_on_stage_cleared)
	proceed_button.pressed.connect(_on_proceed_pressed)
	
	lady_overlay.visible = false
	tutorial_panel.visible = true  # show tutorial, game hasn't started yet

func _on_proceed_pressed() -> void:
	tutorial_panel.visible = false
	start_stage(1)

func start_stage(s: int) -> void:
	current_stage = s
	cake_spawner.start(s)
	present_spawner.spawn(s)

func _on_cake_hit() -> void:
	lives -= 1
	_update_hearts()
	if lives <= 0:
		_lose()

func _update_hearts() -> void:
	heart2.visible = lives >= 2
	heart1.visible = lives >= 1

func _on_stage_cleared() -> void:
	cake_spawner.stop()
	
	if current_stage >= 3:
		_show_dialogue(WIN_DIALOGUE, func():
			emit_signal("minigame_finished", "won")
		)
	else:
		_show_dialogue(STAGE_DIALOGUE[current_stage], func():
			start_stage(current_stage + 1)
		)

func _show_dialogue(text: String, on_done: Callable) -> void:
	lady_overlay.visible = true
	dialogue_label.text = ""

	var typing_tween = create_tween()
	for i in range(text.length()):
		typing_tween.tween_callback(func():
			dialogue_label.text = text.left(dialogue_label.text.length() + 1)
		).set_delay(0.03)

	typing_tween.tween_interval(2.5)
	typing_tween.tween_callback(func():
		lady_overlay.visible = false
		on_done.call()
	)

func _lose() -> void:
	cake_spawner.stop()
	emit_signal("minigame_finished", "dead")
