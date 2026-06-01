# tarot_scene.gd
extends CanvasLayer

signal tarot_won
signal tarot_lost

@onready var dialogue_label = $DialogueBar/DialogueLabel
@onready var speaker_label  = $DialogueBar/SpeakerLabel
@onready var win_lose_panel = $WinLosePanel
@onready var win_button     = $WinLosePanel/WinButton
@onready var lose_button    = $WinLosePanel/LoseButton

const LINES = [
	{ "speaker": "???",          "text": "..." },
	{ "speaker": "???",          "text": "My, my." },
	{ "speaker": "???",          "text": "You've come quite far, little one." },
	{ "speaker": "???",          "text": "And you've brought things with you." },
	{ "speaker": "???",          "text": "Interesting." },
	{ "speaker": "mysterious woman",   "text": "I am the one who reads what remains." },
	{ "speaker": "mysterious woman",   "text": "What has been carried. What has been left behind." },
	{ "speaker": "mysterious woman",   "text": "Shall we see what the cards say about your fate?" },
	{ "speaker": "mysterious woman",   "text": "Let's play a little game, you and I." },
]

var current_line: int = 0
var is_typing: bool = false
var full_text: String = ""
var typing_tween: Tween = null

func _ready() -> void:
	win_lose_panel.visible = false
	win_button.pressed.connect(func(): emit_signal("tarot_won"))
	lose_button.pressed.connect(func(): emit_signal("tarot_lost"))
	
	# fade in
	#modulate.a = 0.0
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 1.0)
	t.tween_callback(func(): _show_line(0))

func _show_line(index: int) -> void:
	if index >= LINES.size():
		win_lose_panel.visible = true
		return
	var line = LINES[index]
	speaker_label.text = line["speaker"]
	_type_text(line["text"])

func _type_text(text: String) -> void:
	full_text = text
	dialogue_label.text = ""
	is_typing = true
	if typing_tween:
		typing_tween.kill()
	typing_tween = create_tween()
	for i in range(text.length()):
		typing_tween.tween_callback(func():
			#dialogue_label.text = full_text.left(dialogue_label.text.length() + 1)
			dialogue_label.text = full_text.substr(0, dialogue_label.text.length() + 1)
		).set_delay(0.03)
	typing_tween.tween_callback(func(): is_typing = false)

func _input(event: InputEvent) -> void:
	if win_lose_panel.visible:
		return
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			if typing_tween:
				typing_tween.kill()
			dialogue_label.text = full_text
			is_typing = false
			return
		current_line += 1
		_show_line(current_line)
