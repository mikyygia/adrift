# main.gd
extends Node2D

# sky scenes & states (very beginning of the game)
@onready var skyScene = $Sky;
var onSkyScene: bool = true;

# fishing assets
@onready var fishingUI = $Game/FishingUI;
@onready var fishingStatus = $Game/FishStatus;

# visual effects / assets (?)
#@onready var animations;

# character assets
@onready var characterBoat =  $Game/characterBoat;

# labels
@onready var hintOverlay = $Game/HintOverlay;
@onready var soulFreedLabel = $Game/VBoxContainer/SoulFreed;

# scenes
@onready var gameScene = $Game;

# dialogue
var dialogue_scene = preload("res://scenes/fish_dialogue.tscn");

# states
var firstFishSeen: bool = false; # so that the first fish displays once
var onDialoguePresent: bool = false;

# item bar
@onready var item_bar = $Game/ItemBar

# ---------------------------------------------------------------------------
# Startup
# ---------------------------------------------------------------------------
func _ready() -> void:
	########### ── DEV SKIP — remove before final build ── ###########
	#firstFishSeen = true
	#GameState.grumpy_freed = true
	#GameState.waiting_lady_won = true
	##GameState.kid_freed = true
	#GameState.freed_souls.append("grumpy_old_man")
	#GameState.freed_souls.append("first_fish")
	#GameState.freed_souls.append("waiting_lady")
	#GameState.freed_souls.append("kid_fish")
	
	
	# simulate having the blank card
	#var card_tex = preload("res://assets/items/blank_card.png")
	#GameState.collected_items["blank_arcana"] = true
	#item_bar.add_item("blank_arcana", "Blank Arcana Card", card_tex)
	
	## music sheet
	#var card_tex2 = preload("res://assets/items/music_sheet.png")
	#GameState.collected_items["music_sheet"] = true
	#item_bar.add_item("music_sheet", "Music Sheet", card_tex2)  
	
	
	
	########### ─────────────────────────────────────────── ###########
	gameScene.visible = false;
	skyScene.visible = true;
	playSkyScene();
	soulFreedLabel.text = "souls freed: " + str(GameState.freed_souls.size())
	
	# show a hint if the user is stuck
	await get_tree().create_timer(3).timeout;
	$Sky/Dialogue/Label.text = "...\npress [space] to proceed"

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if onSkyScene: # don't fish when sky scene is present
		if event.is_action_pressed("ui_accept"):
			onSkyScene = false;
			skyScene.visible = false
			gameStarts();
			
			await get_tree().create_timer(3).timeout;
			showHint("press [f] key to fish");
		return;
	
	if onDialoguePresent: # don't fish when dialogue is present
		return;
	
	if event.is_action_pressed("start fishing"): # start fishing when f is pressed
		startFishing();


# ---------------------------------------------------------------------------
# Scene flow
# ---------------------------------------------------------------------------
func gameStarts():
	SoundManager.unduck_music()
	gameScene.visible = true;
	fishingUI.visible = false;
	fishingStatus.visible = false;
	item_bar.visible = true;
	fishingUI.fishingResults.connect(onFishingEnd);
	
func playSkyScene():
	SoundManager.duck_music()
	# player will wake up looking at the sky
	# dialogue appears  [ ... ]
	onSkyScene = true;
	$Sky/Dialogue/Label.text = "..."
	#$Sky/Dialogue.visible = true;
	show_dialogue();

func show_dialogue():
	var dlg = $Sky/Dialogue
	dlg.visible = true

	# initial state (hidden + small)
	dlg.modulate.a = 0.0
	dlg.scale = Vector2(0.85, 0.85)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(dlg, "modulate:a", 1.0, 1)
	tween.tween_property(dlg, "scale", Vector2(1, 1), 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(dlg, "position:y", dlg.position.y - 10, 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func startFishing():
	SoundManager.duck_music()
	SoundManager.play_sfx("reel")
	
	# set our character on the boat invisible and reset hint overlay
	characterBoat.visible = false;
	hintOverlay.visible = false;
	hintOverlay.text = "";
	fishingStatus.visible = false;
	item_bar.visible = false;
	
	fishingUI.resetState();
	fishingUI.visible = true;

func showHint (text: String):
	hintOverlay.text = text; 

# ---------------------------------------------------------------------------
# Fishing result → pick a fish → show dialogue
# ---------------------------------------------------------------------------
func onFishingEnd(results):
	characterBoat.visible = true;

	if results == 1: # you caught a fish
		GameState.currentFish = pickNextFish();

		if GameState.currentFish == null:
			fishingStatus.text = "The water is quiet... nothing left to find."
			return;

		onDialoguePresent = true;
		showDialogue();
	else:
		characterBoat.visible = true;
		fishingStatus.text = "The fish got away...";

# ++++++++++++++++++++++++++++++++++++++++
# randomized fish pool 
# - tutorial phase (blank fish -> grumpy old man -> waiting lady)
# - open phase
# # ++++++++++++++++++++++++++++++++++++++++
func pickNextFish() -> Fish:
	if not firstFishSeen:
		firstFishSeen = true
		return FishData.getFirstFish()

	# tier 1
	if not GameState.grumpy_freed:
		return FishData.grumpyOldMan()

	if not GameState.waiting_lady_won:
		return FishData.waitingLady()

	# tier 2
	if not GameState.kid_freed:
		return FishData.kidFish()

	if GameState.freed_souls.has("samurai_fish") or GameState.freed_souls.has("samurai_fish_return"):
		return null  # all fish done

	return FishData.samuraiFish()
	
func showDialogue():
	SoundManager.duck_music()
	fishingStatus.visible = false;
	characterBoat.visible = false;
	var dialogue_instance = dialogue_scene.instantiate(); # create the dialogue ; create an address
	add_child(dialogue_instance); # add to tree ; placing address to visible land
	
	dialogue_instance.dialogue_finished.connect(onDialogueFinished);
	dialogue_instance.setup(GameState.currentFish); # puts Fish into instance ; putting furniture into house
	
func onDialogueFinished(outcome: String) -> void:
	fishingStatus.visible = true;
	item_bar.visible = true;
	match outcome:
		"freed":
			characterBoat.visible = true;
			GameState.free_soul(GameState.currentFish.fish_id);
			fishingStatus.text = "this soul dissolves into light...";
			soul_freed_effect()
			onDialoguePresent = false
			
			soulFreedLabel.text = "souls resolved: " + str(GameState.freed_souls.size())

		"ran_away":
			characterBoat.visible = true;
			fishingStatus.text = "The fish got away."
			onDialoguePresent = false
			# No reward
			print("FISH got AWAY — bad end")
			onDialoguePresent = false

		"blackout":
			SoundManager.play_sfx("blackout")
			fishingStatus.text = "The fish got away."
			# Waiting Lady — player ate the cake
			doBlackout("YOU PASSED OUT.\nWhy would you eat something offered by a stranger :/")
			await get_tree().create_timer(3).timeout
			characterBoat.visible = true;
		
		"free_fish":
			GameState.free_soul(GameState.currentFish.fish_id)
			onDialoguePresent = false
			soulFreedLabel.text = "souls freed: " + str(GameState.freed_souls.size())
			var card_tex = preload("res://assets/items/blank_card.png")
			_show_item_obtained("Blank Arcana Card", card_tex, func():
				_give_item("blank_arcana", "Blank Arcana Card", card_tex)
				characterBoat.visible = true
				soul_freed_effect()
				fishingStatus.text = "The soul dissolves into light..."
			)
			
		"minigame":
			fishingStatus.text = ""
			var mg = preload("res://scenes/waiting_lady_minigame.tscn").instantiate()
			mg.name = "WaitingLadyMinigame"
			add_child(mg)
			mg.minigame_won.connect(_on_waitinglady_won)
			mg.minigame_lost.connect(_on_waitinglady_lost)

		"minigame_trivia":
			fishingStatus.text = ""
			var trivia_layer = CanvasLayer.new()
			trivia_layer.layer = 10
			trivia_layer.name = "KidTriviaMinigame"
			add_child(trivia_layer)
			var trivia = load("res://scenes/kid_trivia_minigame.tscn").instantiate()
			trivia_layer.add_child(trivia)
			trivia.trivia_won.connect(_on_trivia_won)
			trivia.trivia_lost.connect(_on_trivia_lost)

		"give_item_friendship", "give_item_pride":
			var sheet_tex = preload("res://assets/items/music_sheet.png")
			_show_item_obtained("Music Sheet", sheet_tex, func():
				_give_item("kid_soundtrack", "Music Sheet", sheet_tex)
				_resume_dialogue(GameState.currentFish, 34)
			)
		
		"choose_item":
			_show_item_picker()

		"give_memory_fragment":
			GameState.collected_items["memory_fragment_teru"] = true
			soul_freed_effect()
			fishingStatus.text = "Something shifts. Like a door left ajar."
			await get_tree().create_timer(2.0).timeout
			GameState.free_soul(GameState.currentFish.fish_id)
			onDialoguePresent = false
			characterBoat.visible = true
			_begin_tarot()

		"tarot_begin":
			GameState.free_soul(GameState.currentFish.fish_id)
			onDialoguePresent = false
			characterBoat.visible = true
			_begin_tarot()
	
	SoundManager.unduck_music()
		
	print("SOUL " + outcome + "\n" 
		+ "Soul Bar: " + str(GameState.soul_bar) + "/" + str(GameState.soul_bar_max) + "\n");

# ---------------------------------------------------------------------------
# Blackout -> fade into minigame
# ---------------------------------------------------------------------------
func doBlackout(message: String) -> void:
	#SoundManager.play_sfx("blackout")
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 18)
	label.modulate.a = 0.0

	overlay.add_child(label)

	var canvas = CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(overlay)
	add_child(canvas)

	var t = create_tween()
	t.tween_property(overlay, "color:a", 1.0, 1.2)
	t.tween_property(label,   "modulate:a", 1.0, 0.5)
	t.tween_interval(3.0)
	t.tween_property(overlay, "color:a", 0.0, 1.0)
	t.tween_callback(canvas.queue_free)
	t.tween_callback(func(): onDialoguePresent = false);

# ---------------------------------------------------------------------------
# Freed Effect -> More engaging animation when soul is freed
# ---------------------------------------------------------------------------
func soul_freed_effect() -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(1, 1, 0.8, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var canvas = CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(overlay)
	add_child(canvas)

	var t = create_tween()
	t.tween_property(overlay, "color:a", 0.6, 0.3)
	t.tween_property(overlay, "color:a", 0.0, 1.2)
	t.tween_callback(canvas.queue_free)

# ---------------------------------------------------------------------------
# waiting lady
# ---------------------------------------------------------------------------
func _on_waitinglady_won() -> void:
	#GameState.free_soul(GameState.currentFish.fish_id);
	var mg = get_node_or_null("WaitingLadyMinigame")
	
	if mg:
		mg.queue_free()
		
	characterBoat.visible = false
	onDialoguePresent = true
	
	_resume_dialogue(GameState.currentFish, 20)  # "I... I'm sorry."	

func _on_waitinglady_lost() -> void:
	var minigame = get_node_or_null("WaitingLadyMinigame")
	if minigame:
		minigame.queue_free()

	GameState.skip_soul("waiting_lady")  # unlocks kid fish, no soul count
		
	doBlackout("The cake hits you square in the face.\nEverything goes dark...")
		
func _resume_dialogue(fish: Fish, from_step: int) -> void:
	characterBoat.visible = false
	onDialoguePresent = true
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance)
	dialogue_instance.dialogue_finished.connect(onDialogueFinished)
	dialogue_instance.setup(fish, from_step)  # ← pass step directly

# ---------------------------------------------------------------------------
# kid fish
# ---------------------------------------------------------------------------
func _on_trivia_won() -> void:
	var minigame = get_node_or_null("KidTriviaMinigame")
	if minigame:
		minigame.queue_free()
	onDialoguePresent = true
	_resume_dialogue(GameState.currentFish, 14)

func _on_trivia_lost() -> void:
	#GameState.free_soul(GameState.currentFish.fish_id);
	var minigame = get_node_or_null("KidTriviaMinigame")
	if minigame:
		minigame.queue_free()
		
	#characterBoat.visible = true
	#fishingStatus.text = "The kid swims away, shaking their head..."
	onDialoguePresent = true
	_resume_dialogue(GameState.currentFish, 36)

func _show_item_picker() -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(dim)

	var label = Label.new()
	label.text = "Choose one:"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(-200, -120)
	label.size = Vector2(400, 40)
	canvas.add_child(label)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.position = Vector2(-150, -60)
	vbox.size = Vector2(300, 180)
	canvas.add_child(vbox)

	var items = [
		{ "label": "An old music sheet", "key": "kid_soundtrack",  "name": "Music Sheet",        "tex": "res://assets/items/music_sheet.png" },
		{ "label": "A smooth river stone",  "key": "smooth_stone",    "name": "Smooth River Stone",  "tex": "res://assets/items/stone.png" },
		{ "label": "A feather charm",  "key": "feather_charm",   "name": "Bent Feather Charm",  "tex": "res://assets/items/feather.png" },
	]

	for item in items:
		var btn = Button.new()
		btn.text = item["label"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key = item["key"]
		var name = item["name"]
		var tex_path = item["tex"]
		btn.pressed.connect(func():
			canvas.queue_free()
			var tex = load(tex_path)
			_show_item_obtained(name, tex, func():
				_give_item(key, name, tex)
				GameState.skip_soul("kid_fish")
				soulFreedLabel.text = "souls freed: " + str(GameState.freed_souls.size())
				characterBoat.visible = true
				fishingStatus.text = "The kid waves goodbye..."
				onDialoguePresent = false
			)
		)
		vbox.add_child(btn)
	
# ---------------------------------------------------------------------------
# tarot lady
# ---------------------------------------------------------------------------
func _begin_tarot() -> void:
	fishingStatus.text = "A figure appears at the edge of the water..."
	await get_tree().create_timer(2.0).timeout

	# manual override panel for your teammate to click
	var panel = preload("res://scenes/tarot_manual.tscn").instantiate()
	add_child(panel)
	panel.tarot_won.connect(_on_tarot_won)
	panel.tarot_lost.connect(_on_tarot_lost)

func _on_tarot_won() -> void:
	# true ending if waiting lady item + music sheet
	# good ending otherwise
	var has_sheet = GameState.collected_items.get("kid_soundtrack", false)
	var has_lady_item = GameState.collected_items.get("blank_arcana", false)

	if has_sheet and has_lady_item:
		_show_ending("true")
	else:
		_show_ending("good")

func _on_tarot_lost() -> void:
	_show_ending("bad")

func _show_ending(type: String) -> void:
	match type:
		"true":
			fishingStatus.text = "True Ending"
		"good":
			fishingStatus.text = "Good Ending"
		"bad":
			fishingStatus.text = "Bad Ending"

# ---------------------------------------------------------------------------
# item being obtained after a minigame. happens post-minigame. waiting lady
# ---------------------------------------------------------------------------
func _show_item_obtained(item_name: String, item_texture: Texture2D, on_done: Callable) -> void:
	var canvas = CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)

	# dim background
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(dim)

	# item sprite — starts small in center
	var item_rect = TextureRect.new()
	item_rect.texture = item_texture
	item_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	item_rect.set_anchors_preset(Control.PRESET_CENTER)
	item_rect.size = Vector2(120, 120)
	item_rect.position = Vector2(-60, -100)
	item_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	item_rect.scale = Vector2(0.1, 0.1)
	item_rect.pivot_offset = Vector2(60, 60)
	canvas.add_child(item_rect)

	# item label — "You obtained: Blank Arcana Card"
	var label = Label.new()
	label.text = "You obtained: " + item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(-200, 60)
	label.size = Vector2(400, 40)
	label.modulate.a = 0.0
	canvas.add_child(label)

	# continue hint
	var hint = Label.new()
	hint.text = "[ press space to continue ]"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_preset(Control.PRESET_CENTER)
	hint.position = Vector2(-200, 100)
	hint.size = Vector2(400, 40)
	hint.modulate.a = 0.0
	canvas.add_child(hint)

	# animate
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(dim, "color:a", 0.6, 0.4)
	t.tween_property(item_rect, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.set_parallel(false)
	t.tween_property(label, "modulate:a", 1.0, 0.4)
	t.tween_property(hint, "modulate:a", 1.0, 0.3)

	# wait for space
	await _wait_for_space()
	
	var t2 = create_tween()
	t2.tween_property(canvas, "modulate:a", 0.0, 0.4)
	t2.tween_callback(canvas.queue_free)
	t2.tween_callback(on_done)

func _wait_for_space() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			break

func _give_item(key: String, name: String, texture: Texture2D) -> void:
	GameState.collected_items[key] = true
	item_bar.add_item(key, name, texture)
