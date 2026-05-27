extends CanvasLayer

# ---------------------------------------------------------------------------
# fish_dialogue.gd — attached to fish_dialogue.tscn CanvasLayer.
#
#   fishDialogue 
#     └─ control
#           VBoxContainer/
#             alias       (Label)
#             dialogue    (Label)
#             choices     (VBoxContainer)
#           portrait      (TextureRect)
# ---------------------------------------------------------------------------

signal dialogue_finished(outcome: String)
# outcome values: "escaped", "ran_away", "blackout", "minigame"

@onready var alias_label    = $control/Panel/HBoxContainer/VBoxContainer/alias
@onready var dialogue_label = $control/Panel/HBoxContainer/VBoxContainer/dialogue
@onready var choices_box    = $control/Panel/HBoxContainer/VBoxContainer/choices
@onready var portrait_rect  = $control/Panel/HBoxContainer/portrait

var fish: Fish;
var current_step: int = 0; # bookmark of where you are in dialogue array cuz fish dialogue is just an array of steps
var waiting_for_input: bool = false # should pressing space/enter do anything right now?

# creating a typewriter effect
var is_typing: bool = false
var full_text: String = ""
var typing_tween: Tween = null
var typing_delay: float = 0.03; # adjust typing speed

const PLAYER_PORTRAIT = preload("res://assets/character/boy.png")

# something
signal emotion_changed(emotion: String);

# ---------------------------------------------------------------------------
#  ui setup display for the text and portrait
# ---------------------------------------------------------------------------
func setup(f: Fish, start_step: int = 0) -> void:
	fish = f
	current_step = start_step
	alias_label.text = fish.fish_name.to_upper()
	updatePortrait("default")
	_show_step(current_step)

func updatePortrait(emotion: String):
	if GameState.currentFish == null:
		return;
		
	# set a default portrait
	var tex = GameState.currentFish.portraits.get(
		emotion,
		GameState.currentFish.portraits.get("default")
	)
	
	# if texture is set then set it
	if tex:
		portrait_rect.texture = tex

# ---------------------------------------------------------------------------
#  the gear of the dialogue engine:
# - changes fish portrait based on dialogue
# - jumps to the next dialogue if applicable
# ---------------------------------------------------------------------------
func _show_step(index: int) -> void:
	if index >= fish.dialogue.size():
		_end("escaped")
		return

	var step: Dictionary = fish.dialogue[index]
	_clear_choices()
	
	if step.has("portrait") and step["portrait"] == "player":
		portrait_rect.texture = PLAYER_PORTRAIT
	elif step.has("emotion"):
		updatePortrait(step["emotion"])

	var speaker = step.get("speaker", "fish")
	
	match speaker:
		"fish":
			alias_label.text = fish.fish_name.to_upper()
			if not step.has("portrait") and not step.has("emotion"):
				updatePortrait("default")  # ← add this
			waiting_for_input = true
			type_text(step["text"])

		"player":
			alias_label.text = "YOU"
			dialogue_label.text = ""
			waiting_for_input = false
			
			if not step.has("choices"):
				push_warning("Player step at index " + str(index) + " has no choices key")
				waiting_for_input = true
				type_text(step.get("text", "..."))
			else:
				var choices = step["choices"]
				# if this is the teru item loop, rebuild choices fresh each time
				if step.get("is_item_prompt", false):
					var has_sheet   = GameState.collected_items.get("kid_soundtrack", false)
					var has_card    = GameState.collected_items.get("blank_arcana", false)
					var has_stone   = GameState.collected_items.get("smooth_stone", false)
					var has_feather = GameState.collected_items.get("feather_charm", false)
					choices = FishData._buildTeruItemChoices(has_sheet, has_card, has_stone, has_feather)
				_build_choices(choices)

		"monologue":
			alias_label.text = "..."
			if not step.has("portrait") and not step.has("emotion"):
				updatePortrait("default")  # ← and this
			waiting_for_input = true
			type_text(step["text"])
			
		


# ---------------------------------------------------------------------------
#  typewriter effect while fishes are talking
# ---------------------------------------------------------------------------
func type_text(text: String) -> void:
	full_text = text
	dialogue_label.text = ""
	is_typing = true

	if typing_tween:
		typing_tween.kill()

	typing_tween = create_tween()

	for i in range(text.length()):
		typing_tween.tween_callback(func(): 
			dialogue_label.text = full_text.left(dialogue_label.text.length() + 1)
		).set_delay(typing_delay)  # adjust speed here — lower = faster

	typing_tween.tween_callback(func():
		is_typing = false;
		waiting_for_input = true
	)

# ---------------------------------------------------------------------------
#  turning off keyboard advancement until a choice is made
# ---------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		# if is still typing, skip to full text
		if is_typing:
			if typing_tween:
				typing_tween.kill()
			dialogue_label.text = full_text
			is_typing = false
			waiting_for_input = true;
			return
		
		 # otherwise, ignore ALL input, if false
		if not waiting_for_input:
			return;
		
		# Fish is talking, player reads and presses space to continue			
		waiting_for_input = false;

		var step = fish.dialogue[current_step]
		
		if step.has("next"):
			_resolve_next(step["next"])
		else:
			current_step += 1
			_show_step(current_step)

# ---------------------------------------------------------------------------
#  building how the choices are displayed
# ---------------------------------------------------------------------------
func _build_choices(choices: Array) -> void:
	for choice in choices:
		var btn = Button.new()
		btn.text = "> " + choice["label"]
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		# autowrap so long choices don't get cut off
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 0)
		
		var is_disabled = choice.get("disabled", false)
		btn.disabled = is_disabled
		
		# normal state — transparent
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(0, 0, 0, 0)
		btn.add_theme_stylebox_override("normal", normal)
		
		# hover state — slight dark tint
		var hover = StyleBoxFlat.new()
		hover.bg_color = Color(0, 0, 0, 0.15)
		btn.add_theme_stylebox_override("hover", hover)
		
		if is_disabled:
			# grayed out — player can see it but not click
			btn.add_theme_color_override("font_color",       Color(0.4, 0.4, 0.4, 0.6))
			btn.add_theme_color_override("font_hover_color", Color(0.4, 0.4, 0.4, 0.6))
		else:
			btn.add_theme_color_override("font_hover_color", Color(0.641, 0.399, 0.719, 1.0))

		if not is_disabled:
			var next_val = choice["next"]
			btn.pressed.connect(func():
				SoundManager.play_click()
				_on_choice_pressed(next_val))

		choices_box.add_child(btn)

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()

func _on_choice_pressed(next_val) -> void:
	_clear_choices()
		
	# set offered flags for teru item loop
	if next_val == 41:  # music sheet
		GameState.flags["teru_offered_sheet"] = true
		GameState.flags["teru_offered_anything"] = true
	elif next_val in [78, 85, 90]:  # stone, feather, card
		GameState.flags["teru_offered_anything"] = true
	
	_resolve_next(next_val)

func _resolve_next(next_val) -> void:
	# Special string signals
	if next_val is String:
		_end(next_val)
		return

	match next_val:
		-1:  # good end — fish escapes
			_end("freed")
		-2:  # bad end — fish runs away
			_end("ran_away")
		-3: # blackout -> waiting lady or could become future fish in general
			_end("blackout")
		_:   # jump to step index
			current_step = next_val
			_show_step(current_step)

func _end(outcome: String) -> void:
	waiting_for_input = false
	emit_signal("dialogue_finished", outcome)
	queue_free()
