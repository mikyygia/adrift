extends Control

@onready var bar = $Bar;
@onready var target = $TargetZone;
@onready var tick = $Tick;
#@onready var goal = $Goal;
@onready var progress_bar = $ProgressBar;

@onready var barLeftBound = bar.position.x;
@onready var barRightBound = bar.position.x + bar.size.x;

# movement
var speed := 300;
var direction := 1;

# game loop
var effort = 4; # starting amount
var effortGoal = 30; # amount needed to reel

var successGain = 9; # effort gained when landed on target
var failPenalty = 3; # effort loss when fail to land on target

var minTargetWidth = 20;
var targetShrinkAmount = 3;

# communicate with main ui
signal fishingResults(results);

func _ready() -> void:	
	$".".visible = false;
	tick.position.y = bar.position.y - 5;
	#goal.text = "Goal: " + str(effort) + "/" + str(effortGoal);
	progress_bar.min_value = 0
	progress_bar.max_value = effortGoal
	progress_bar.value = effort
	
	# set & randomize target starting positon
	randomizeTarget();
	target.position.y = bar.position.y;

func _process(delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	if not is_visible_in_tree():
		return
	
	tick.position.x += speed * direction * delta;
	
	# trailing shadow when tick moves
	var ghost = ColorRect.new()
	ghost.size = tick.size
	ghost.color = Color(1, 1, 1, 0.3)
	var parent = tick.get_parent()
	parent.add_child(ghost)
	ghost.position = tick.position
	var t = create_tween()
	t.tween_property(ghost, "modulate:a", 0.0, 0.15)
	t.tween_callback(ghost.queue_free)
	
	if (tick.position.x <= barLeftBound):
		tick.position.x = barLeftBound;
		direction = 1;
	elif (tick.position.x >= barRightBound):
		tick.position.x = barRightBound;
		direction = -1;

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if (event.is_action_pressed("ui_accept")):
		checkSuccess();
		updateGoal();

func checkSuccess():
	var tickX = tick.position.x;

	var targetMin = target.position.x;
	var targetMax = target.position.x + target.size.x;
	
	var inBound = (tickX >= targetMin and tickX <= targetMax);
	
	if inBound:
		
		effort += successGain;
		
		SoundManager.play_sfx("bar-success")
		# flash green when you succeed
		var t = create_tween()
		t.tween_property(bar, "modulate", Color(0.5, 1.0, 0.5), 0.05)
		t.tween_property(bar, "modulate", Color(1, 1, 1), 0.2)
		SoundManager.play_sfx("reel_hit")
		
		var pulse = create_tween()
		pulse.tween_property(tick, "scale", Vector2(1.3, 1.3), 0.05)
		pulse.tween_property(tick, "scale", Vector2(1.0, 1.0), 0.1)
		
		if effort >= effortGoal:
			endFishing(1);
			
		
		# don't shrink and increase speed if target zone less than 40
		if target.size.x > 40:
			shrinkTarget(-20);
			setTickSpeed(100);
	else:
		effort -= failPenalty;
		
		SoundManager.play_sfx("bar-fail")
		# flash red when you miss
		var t = create_tween()
		t.tween_property(bar, "modulate", Color(1.0, 0.4, 0.4), 0.05)
		t.tween_property(bar, "modulate", Color(1, 1, 1), 0.2)
		SoundManager.play_sfx("reel_miss")
		
		# bar wobbles a bit when you miss
		var shake = create_tween()
		shake.tween_property(bar, "rotation_degrees", 2.0, 0.05)
		shake.tween_property(bar, "rotation_degrees", -2.0, 0.05)
		shake.tween_property(bar, "rotation_degrees", 0.0, 0.05)
		
		if effort <= 0:
			endFishing(0);
		
		if target.size.x <= 35 :
			shrinkTarget(10); # make wider when player struggling
			targetShrinkAmount += 1; # fail penalty increase
			
			if speed > 30: # to prevent tick suddenly stops moving ...
				setTickSpeed(-30); 
	
	randomizeTarget();

func shrinkTarget(targetWidth):
	# (+, -)-> (wider, smaller) | num -> width
	
	#if target.size.x >= 35:
	target.custom_minimum_size.x += targetWidth;
	target.size.x += targetWidth;

func randomizeTarget():
	var randomX = randi_range(barLeftBound, barRightBound - target.size.x);
	target.position.x = randomX;
	
func setTickSpeed(x):
	speed += x;
	
func updateGoal():
	#goal.text = "Goal: " + str(effort) + "/" + str(effortGoal);
	progress_bar.value = effort

func endFishing(status: int):
	# printing is mostly for debugging. doesn't appear in the UI
	if status == 1:
		print("FISH WAS CAUGHT!");
		# fish dialogue appears
	else:
		print("FISH GOT AWAY!");

	$".".visible = false;
	get_tree().paused = false;
	
	emit_signal("fishingResults", status);
	
func resetState():
	effort = 7
	speed = 300
	direction = 1

	# reset target size back to original
	target.custom_minimum_size.x = 80 
	target.size.x = 80

	# reset tick position to start
	tick.position.x = barLeftBound;

	randomizeTarget();
	updateGoal();
