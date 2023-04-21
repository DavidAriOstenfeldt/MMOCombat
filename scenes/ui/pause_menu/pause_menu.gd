extends CanvasLayer

@export var settings_menu: CanvasLayer

@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var return_to_game_button: Button = %ReturnToGameButton


func _ready() -> void:
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	return_to_game_button.pressed.connect(on_return_to_game_pressed)
	


func _unhandled_key_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("cancel"):
			get_viewport().set_input_as_handled()
			close()


func close() -> void:
	visible = false


func on_options_pressed() -> void:
	close()
	if settings_menu != null:
		settings_menu.visible = true

func on_quit_pressed() -> void:
	get_tree().quit()
	
	
func on_return_to_game_pressed() -> void:
	close()
