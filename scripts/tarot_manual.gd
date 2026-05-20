# tarot_manual.gd
extends CanvasLayer

signal tarot_won
signal tarot_lost

func _ready() -> void:
	$WinButton.pressed.connect(func(): emit_signal("tarot_won"))
	$LoseButton.pressed.connect(func(): emit_signal("tarot_lost"))
