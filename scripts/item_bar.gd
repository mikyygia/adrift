extends CanvasLayer

@onready var hbox = $HBoxContainer

const ITEM_SIZE = Vector2(48, 48)

var expanded_panel: Control = null  # currently open panel if any

func add_item(item_key: String, item_name: String, item_texture: Texture2D) -> void:
	var btn = TextureButton.new()
	btn.texture_normal = item_texture
	btn.custom_minimum_size = ITEM_SIZE
	btn.pressed.connect(func(): _expand_item(btn, item_name, item_texture))
	hbox.add_child(btn)

func _expand_item(source_btn: TextureButton, item_name: String, item_texture: Texture2D) -> void:
	# close any already open panel
	if expanded_panel:
		expanded_panel.queue_free()
		expanded_panel = null
		return

	var panel = Panel.new()
	panel.size = Vector2(200, 220)
	
	# position below the hbox
	panel.position = Vector2(
		source_btn.global_position.x - 80,
		source_btn.global_position.y + ITEM_SIZE.y + 8
	)
	expanded_panel = panel

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# close button
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	close_btn.flat = false
	close_btn.pressed.connect(func():
		panel.queue_free()
		expanded_panel = null
	)
	vbox.add_child(close_btn)

	# item image
	var img = TextureRect.new()
	img.texture = item_texture
	img.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	img.custom_minimum_size = Vector2(100, 100)
	img.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(img)

	# item name
	var lbl = Label.new()
	lbl.text = item_name
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl)

	add_child(panel)
