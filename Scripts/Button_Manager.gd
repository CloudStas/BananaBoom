extends VBoxContainer

@export var hover_scale := Vector2(1.1, 1.1)
@export var hover_duration := 0.12

func _ready() -> void:
	var play_button = get_node_or_null("PlayButton")
	if play_button is BaseButton:
		play_button.pressed.connect(_on_play_pressed)
		_setup_hover_effect(play_button)
	else:
		push_error("PlayButton not found")

	var options_button = get_node_or_null("OptionsButton")
	if options_button is BaseButton:
		options_button.pressed.connect(_on_options_pressed)
		_setup_hover_effect(options_button)
	else:
		push_error("OptionsButton not found")

	var quit_button = get_node_or_null("QuitButton")
	if quit_button is BaseButton:
		quit_button.pressed.connect(_on_quit_pressed)
		_setup_hover_effect(quit_button)
	else:
		push_error("QuitButton not found")
	
	var GameLogo = get_node_or_null("GameLogo")
	if GameLogo is BaseButton:
		GameLogo.pressed.connect(_on_quit_pressed)
		_setup_hover_effect(GameLogo)
	else:
		push_error("GameLogo not found")

func _setup_hover_effect(button: Control) -> void:
	await get_tree().process_frame
	button.pivot_offset = button.size / 2
	
	button.mouse_entered.connect(_on_button_hover.bind(button, hover_scale))
	button.mouse_exited.connect(_on_button_hover.bind(button, Vector2.ONE))

func _on_button_hover(button: Control, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, hover_duration)

func _on_play_pressed() -> void:
	_animate_to($"../PlayMenu")

func _on_options_pressed() -> void:
	_animate_to($"../OptionsMenu")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _animate_to(target_menu: Control) -> void:
	if not target_menu:
		return
		
	self.pivot_offset = self.size / 2
	target_menu.pivot_offset = target_menu.size / 2
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	
	tween.tween_callback(func():
		self.visible = false
		target_menu.scale = Vector2.ZERO
		target_menu.visible = true
	)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target_menu, "scale", Vector2.ONE, 0.2)
