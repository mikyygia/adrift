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
@onready var soulMetLabel = $Game/VBoxContainer/SoulMet;

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
	
	fishingUI.resetState();
	fishingUI.visible = true;


func showHint (text: String):
	hintOverlay.text = text; 

# ---------------------------------------------------------------------------
# Fishing result → pick a fish → show dialogue
# ---------------------------------------------------------------------------
func onFishingEnd(results):
	characterBoat.visible = true;
	fishingStatus.visible = true;

	if results == 1: # you caught a fish
		GameState.currentFish = pickRandomFish();

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
func pickRandomFish():
	if not firstFishSeen:
		firstFishSeen = true;
		return FishData.getFirstFish();

	# weighted roll : 70% common, 30% heavy, or whatever feels right
	var roll = randf();
	var pool: Array;

	if roll < 0.7:
		pool = FishData.getGentlePool();
		if pool.is_empty():  # fallback if all gentle fish freed
			pool = FishData.getHeavyPool();
	else:
		pool = FishData.getHeavyPool();
		if pool.is_empty():  # fallback if all heavy fish freed
			pool = FishData.getGentlePool();
	
	if pool.is_empty():
		return null  # TODO: handle "all fish freed" end state
	
	return pool[randi() % pool.size()];
	
func showDialogue():
	characterBoat.visible = false;
	var dialogue_instance = dialogue_scene.instantiate(); # create the dialogue ; create an address
	add_child(dialogue_instance); # add to tree ; placing address to visible land
	
	dialogue_instance.dialogue_finished.connect(onDialogueFinished);
	dialogue_instance.setup(GameState.currentFish); # puts Fish into instance ; putting furniture into house
	
func onDialogueFinished(outcome: String) -> void:
	match outcome:
		"freed":
			characterBoat.visible = true;
			GameState.free_soul(GameState.currentFish.fish_id);
			fishingStatus.text = "The soul dissolves into light...";
			soul_freed_effect()
			onDialoguePresent = false

		"ran_away":
			characterBoat.visible = true;
			fishingStatus.text = "The fish got away."
			# No reward
			print("FISH got AWAY — bad end")
			onDialoguePresent = false

		"blackout":
			# Waiting Lady — player ate the cake
			fishingStatus.text = "you passed out...";
			doBlackout("YOU PASSED OUT.\nWhy would you eat something offered by a stranger :/")

		"minigame":
			print("MINIGAME OUTCOME TRIGGERED")
			var mg = preload("res://scenes/waiting_lady_minigame.tscn").instantiate()
			add_child(mg)
			mg.minigame_finished.connect(func(outcome):
				mg.queue_free()
				onDialoguePresent = false
				characterBoat.visible = true
				if outcome == "won":
					GameState.free_soul(GameState.currentFish.fish_id)
					fishingStatus.text = "The soul dissolves into light..."
				else:
					fishingStatus.text = "You couldn't hold on..."
			)
			
	print("SOUL " + outcome + "\n" 
		+ "Soul Bar: " + str(GameState.soul_bar) + "/" + str(GameState.soul_bar_max) + "\n" 
		+ "Current Tier: " + str(GameState.soul_tier));

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
