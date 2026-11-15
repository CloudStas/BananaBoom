extends VBoxContainer

@onready var main_menu = get_node_or_null("../MainMenu")
var hover_scale: Vector2 = Vector2(1.1, 1.1)

func _ready() -> void:
	var back_button = get_node_or_null("Top/BackButton")
	
	if back_button is BaseButton:
		back_button.pressed.connect(_on_back_pressed)
	else:
		push_error("BackButton not found")
		
	var Level1Button = get_node_or_null("Level1Button")
	if Level1Button is BaseButton:
		Level1Button.pressed.connect(_on_level_1_pressed)
		_setup_hover_effect(Level1Button)
	else:
		push_error("Level1Button not found")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func _setup_hover_effect(button: Control) -> void:
	await get_tree().process_frame
	button.pivot_offset = button.size / 2
	
	button.mouse_entered.connect(_on_button_hover.bind(button, hover_scale))
	button.mouse_exited.connect(_on_button_hover.bind(button, Vector2.ONE))

func _on_button_hover(button: Control, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.15)

func _on_back_pressed() -> void:
	if not main_menu:
		return
	
	self.pivot_offset = self.size / 2
	main_menu.pivot_offset = main_menu.size / 2
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)

	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	
	tween.tween_callback(func():
		self.visible = false
		main_menu.scale = Vector2.ZERO
		main_menu.visible = true
	)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(main_menu, "scale", Vector2.ONE, 0.2)
