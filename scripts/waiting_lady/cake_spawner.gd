# cake_spawner.gd
extends Node

signal cake_hit_player

@export var cake_scene: PackedScene

var screen_size: Vector2
var timer: Timer
var active: bool = false

# stage configs — [min_cakes, max_cakes, min_speed, max_speed]
const STAGE_CONFIGS = [
	{ "min_cakes": 3, "max_cakes": 5, "min_speed": 160.0, "max_speed": 220.0 },  # stage 1
	{ "min_cakes": 4, "max_cakes": 6, "min_speed": 180.0, "max_speed": 260.0 },  # stage 2
	{ "min_cakes": 5, "max_cakes": 8, "min_speed": 250.0, "max_speed": 300.0 },  # stage 3
]

var current_config: Dictionary

func _ready() -> void:
	screen_size = get_tree().root.get_visible_rect().size;
	timer = Timer.new()
	timer.wait_time = 3.0
	timer.timeout.connect(_spawn_wave)
	add_child(timer)

func start(stage: int) -> void:
	current_config = STAGE_CONFIGS[stage - 1]
	active = true
	_spawn_wave()   # spawn immediately on start, don't wait 3s
	timer.start()

func stop() -> void:
	active = false
	timer.stop()

func _spawn_wave() -> void:
	if not active:
		return
	var count = randi_range(current_config.min_cakes, current_config.max_cakes)
	for i in range(count):
		var cake = cake_scene.instantiate()
		cake.position = Vector2(randf_range(40, screen_size.x - 40), -40)
		cake.speed = randf_range(current_config.min_speed, current_config.max_speed)
		
		cake.hit_player.connect(func(): 
			if is_instance_valid(cake):
				emit_signal("cake_hit_player")
		)
		
		get_parent().add_child(cake)
