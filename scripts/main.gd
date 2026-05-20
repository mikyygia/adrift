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
#var currentFish: Fish = null;
var onDialoguePresent: bool = false;


# ---------------------------------------------------------------------------
# Startup
# ---------------------------------------------------------------------------
func _ready() -> void:
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
	gameScene.visible = true;
	fishingUI.visible = false;
	fishingStatus.visible = false;
	fishingUI.fishingResults.connect(onFishingEnd);

func playSkyScene():
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
	# set our character on the boat invisible and reset hint overlay
	characterBoat.visible = false;
	hintOverlay.visible = false;
	hintOverlay.text = "";
	fishingStatus.visible = false;
	
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
	fishingStatus.visible = false;
	characterBoat.visible = false;
	var dialogue_instance = dialogue_scene.instantiate(); # create the dialogue ; create an address
	add_child(dialogue_instance); # add to tree ; placing address to visible land
	
	dialogue_instance.dialogue_finished.connect(onDialogueFinished);
	dialogue_instance.setup(GameState.currentFish); # puts Fish into instance ; putting furniture into house
	
func onDialogueFinished(outcome: String) -> void:
	fishingStatus.visible = true;
	match outcome:
		"freed":
			characterBoat.visible = true;
			GameState.free_soul(GameState.currentFish.fish_id);
			fishingStatus.text = "The soul dissolves into light...";
			soul_freed_effect()
			onDialoguePresent = false
			
			soulFreedLabel.text = "souls freed: " + str(GameState.freed_souls.size())

		"ran_away":
			characterBoat.visible = true;
			fishingStatus.text = "The fish got away."
			onDialoguePresent = false
			# No reward
			print("FISH got AWAY — bad end")
			onDialoguePresent = false

		"blackout":
			fishingStatus.text = "The fish got away."
			# Waiting Lady — player ate the cake
			doBlackout("YOU PASSED OUT.\nWhy would you eat something offered by a stranger :/")
			await get_tree().create_timer(3).timeout
			characterBoat.visible = true;
			
			
		"minigame":
			fishingStatus.text = ""
			var mg = preload("res://scenes/waiting_lady_minigame.tscn").instantiate()
			mg.name = "WaitingLadyMinigame"
			add_child(mg)
			mg.minigame_won.connect(_on_waitinglady_won)
			mg.minigame_lost.connect(_on_waitinglady_lost)

		"minigame_trivia":
			fishingStatus.text = ""
			print("TRIVIA MINIGAME TRIGGERED")
			var trivia = load("res://scenes/kid_trivia_minigame.tscn").instantiate()
			trivia.name = "KidTriviaMinigame"
			add_child(trivia)
			trivia.trivia_won.connect(_on_trivia_won)
			trivia.trivia_lost.connect(_on_trivia_lost)
			# onDialoguePresent stays TRUE until trivia ends

		"give_item_friendship":
			GameState.collected_items["kid_soundtrack"] = true
			_resume_dialogue(GameState.currentFish, 32)

		"give_item_pride":
			GameState.collected_items["kid_soundtrack"] = true
			_resume_dialogue(GameState.currentFish, 32)
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
		
	print("SOUL " + outcome + "\n" 
		+ "Soul Bar: " + str(GameState.soul_bar) + "/" + str(GameState.soul_bar_max) + "\n");

# ---------------------------------------------------------------------------
# Blackout -> fade into minigame
# ---------------------------------------------------------------------------
func doBlackout(message: String) -> void:
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

func _on_waitinglady_won() -> void:
	GameState.free_soul(GameState.currentFish.fish_id);
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
		doBlackout("The cake hits you square in the face.\nEverything goes dark...")
		
func _resume_dialogue(fish: Fish, from_step: int) -> void:
	characterBoat.visible = false
	onDialoguePresent = true
	var dialogue_instance = dialogue_scene.instantiate()
	add_child(dialogue_instance)
	dialogue_instance.dialogue_finished.connect(onDialogueFinished)
	dialogue_instance.setup(fish, from_step)  # ← pass step directly

func _on_trivia_won() -> void:
	var minigame = get_node_or_null("KidTriviaMinigame")
	if minigame:
		minigame.queue_free()
	onDialoguePresent = true
	_resume_dialogue(GameState.currentFish, 12)

func _on_trivia_lost() -> void:
	GameState.free_soul(GameState.currentFish.fish_id);
	var minigame = get_node_or_null("KidTriviaMinigame")
	if minigame:
		minigame.queue_free()
	characterBoat.visible = true
	fishingStatus.text = "The kid swims away, shaking their head..."
	onDialoguePresent = false
	
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
