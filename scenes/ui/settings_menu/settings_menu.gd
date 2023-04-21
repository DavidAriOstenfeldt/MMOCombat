extends CanvasLayer

@export var back_menu: CanvasLayer

@onready var sound_slider: HSlider = %SoundSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var music_volume_label: Label = %MusicVolumeLabel
@onready var sound_volume_label: Label = %SoundVolumeLabel
@onready var window_mode_button: OptionButton = %WindowModeButton
@onready var combat_messages_button: OptionButton = %CombatMessagesButton
@onready var back_button: Button = %BackButton
@onready var resolution_button: OptionButton = %ResolutionButton


func _ready() -> void:
	back_button.pressed.connect(on_back_pressed)
	window_mode_button.item_selected.connect(on_window_button_pressed)
	combat_messages_button.item_selected.connect(on_combat_messages_button_pressed)
	resolution_button.item_selected.connect(on_resolution_button_button_pressed)
	sound_slider.value_changed.connect(on_audio_slider_changed.bind("Sound"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("Music"))
	
	sound_slider.value = get_bus_volume_percent("Sound")
	music_slider.value = get_bus_volume_percent("Music")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		close()


func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	if bus_name == "Sound":
		sound_volume_label.text = "%d" % (percent * 100)
	elif bus_name == "Music":
		music_volume_label.text = "%d" % (percent*100)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func close() -> void:
	visible = false


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)


func on_combat_messages_button_pressed(index: int) -> void:
	if index == 0:
		# Enabled
		CombatEvents.print_combat_events = true
	elif index == 1:
		# Disabled
		CombatEvents.print_combat_events = false


func on_window_button_pressed(index: int) -> void:
	if index == 0:
		# Windowed
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		# Windowed Borderless
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 2:
		# Full Screen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func on_resolution_button_button_pressed(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_size(Vector2(1280, 720))
	elif index == 1:
		DisplayServer.window_set_size(Vector2(1366, 768))
	elif index == 2:
		DisplayServer.window_set_size(Vector2(1600, 900))
	elif index == 3:
		DisplayServer.window_set_size(Vector2(1920, 1080))
	elif index == 4:
		DisplayServer.window_set_size(Vector2(2560, 1440))
	elif index == 5:
		DisplayServer.window_set_size(Vector2(3840, 2160))

func on_back_pressed() -> void:
	close()
	if back_menu != null:
		back_menu.visible = true
