extends HBoxContainer

@onready var boat = $"../RowboatPixel";
@onready var cloud = $"../cloud";

func _ready() -> void:
	cloud.modulate.a = 1;
	var t = get_tree().create_tween()
	t.tween_property(cloud, "modulate:a", 0.0, 4.0)

func _process(_float) -> void:
	# move the boat across the scene
	if boat.position.x >= -200: 
			boat.position.x -= 0.35;
	else:
		boat.position.x = 1000;
	
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn");
