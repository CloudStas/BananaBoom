extends VBoxContainer

@onready var main_menu = get_node_or_null("../MainMenu")
@onready var volume_value_label = get_node_or_null("Volume/VolumeValue")

func _ready() -> void:
	var back_button = get_node_or_null("Top/BackButton")
	if back_button is BaseButton:
		back_button.pressed.connect(_on_back_pressed)
	else:
		push_error("BackButton not found")

	var volume_slider = get_node_or_null("Volume/VolumeSlider")
	if volume_slider is Range:
		volume_slider.value_changed.connect(_on_volume_changed)
		_on_volume_changed(volume_slider.value)
	else:
		push_error("VolumeSlider not found")

	var music_checkbox = get_node_or_null("MusicContainer/MusicCheckbox")
	if music_checkbox is BaseButton:
		music_checkbox.toggled.connect(_on_music_toggled)
	else:
		push_error("MusicCheckbox not found")

	var sfx_checkbox = get_node_or_null("SFXContainer/SFXCheckbox")
	if sfx_checkbox is BaseButton:
		sfx_checkbox.toggled.connect(_on_sfx_toggled)
	else:
		push_error("SFXCheckbox not found")

func _on_volume_changed(value: float) -> void:
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value))
	
	if volume_value_label:
		volume_value_label.text = str(roundi(value * 100)) + "%"

func _on_music_toggled(toggled_on: bool) -> void:
	var music_index = AudioServer.get_bus_index("Music")
	if music_index != -1:
		AudioServer.set_bus_mute(music_index, not toggled_on)

func _on_sfx_toggled(toggled_on: bool) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, not toggled_on)

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
