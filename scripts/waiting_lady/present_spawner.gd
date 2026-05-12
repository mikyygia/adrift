# present_spawner.gd
extends Node

signal all_collected

@export var present_scene: PackedScene

const PRESENTS_PER_STAGE = [1, 1, 1];

var screen_size: Vector2
var presents_remaining: int = 0

func _ready() -> void:
	screen_size = get_tree().root.get_visible_rect().size


func spawn(stage: int) -> void:
	presents_remaining = PRESENTS_PER_STAGE[stage - 1]
	var positions_used: Array = []
	
	for i in range(presents_remaining):
		var present = present_scene.instantiate()
		present.position = _find_position(positions_used)
		positions_used.append(present.position)
		present.collected.connect(_on_present_collected)
		get_parent().add_child(present)

func _find_position(used: Array) -> Vector2:
	var attempts = 0
	while attempts < 30:
		var x = randf_range(60, screen_size.x - 60)
		var y = randf_range(60, screen_size.y * 0.65)
		var candidate = Vector2(x, y)
		var too_close = used.any(func(p): return candidate.distance_to(p) < 80)
		if not too_close:
			return candidate
		attempts += 1
	return Vector2(randf_range(60, screen_size.x - 60), randf_range(60, screen_size.y * 0.5))

func _on_present_collected() -> void:
	presents_remaining -= 1
	if presents_remaining <= 0:
		emit_signal("all_collected")
	
