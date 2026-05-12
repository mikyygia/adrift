extends Control

@onready var bar = $Bar;
@onready var target = $TargetZone;
@onready var tick = $Tick;
@onready var goal = $Goal;

@onready var barLeftBound = bar.position.x;
@onready var barRightBound = bar.position.x + bar.size.x;

# movement
var speed := 300;
var direction := 1;

# game loop
var effort = 7; # starting amount
var effortGoal = 30; # amount needed to reel

var successGain = 15; # effort gained when landed on target
var failPenalty = 5; # effort loss when fail to land on target

var minTargetWidth = 20;
var targetShrinkAmount = 5;

# communicate with main ui
signal fishingResults(results);

func _ready() -> void:	
	$".".visible = false;
	tick.position.y = bar.position.y - 5;
	goal.text = "Goal: " + str(effort) + "/" + str(effortGoal);
	
	# set & randomize target starting positon
	randomizeTarget();
	target.position.y = bar.position.y;

func _process(delta: float) -> void: # Called every frame. 'delta' is the elapsed time since the previous frame.
	if not is_visible_in_tree():
		return
		
	tick.position.x += speed * direction * delta;
	
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
		
		if effort >= effortGoal:
			endFishing(1);
			
		shrinkTarget(-20);
		setTickSpeed(100);
	else:
		effort -= failPenalty;
		
		if effort <= 0:
			endFishing(0);
		
		if target.size.x <= 40 :
			shrinkTarget(5); # make wider when player struggling
			targetShrinkAmount += 1; # fail penalty increase
			
			if speed > 30: # to prevent tick suddenly stops moving ...
				setTickSpeed(-30); 
	
	randomizeTarget();

func shrinkTarget(targetWidth):
	# (+, -)-> (wider, smaller) | num -> width
	
	if target.size.x >= 35:
		target.custom_minimum_size.x += targetWidth;
		target.size.x += targetWidth;

func randomizeTarget():
	var randomX = randi_range(barLeftBound, barRightBound - target.size.x);
	target.position.x = randomX;
	
func setTickSpeed(x):
	speed += x;
	
func updateGoal():
	goal.text = "Goal: " + str(effort) + "/" + str(effortGoal);

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
