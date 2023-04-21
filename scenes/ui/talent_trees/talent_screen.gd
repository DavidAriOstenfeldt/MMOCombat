extends CanvasLayer

@onready var talent_tooltip: PanelContainer = %TalentTooltip
@onready var talent_buttons = get_tree().get_nodes_in_group("talent_tree_button")
@onready var talent_tree_container: TabContainer = %TalentTreeContainer
var player: Player

var talent_points_total = null
var talent_points_left = null
var talent_points_spent = 0

var mouse_inside: bool = false

func _ready() -> void:
	await get_tree().process_frame
	for talent_button in talent_buttons:
		talent_button = talent_button as TalentTreeButton
		talent_button.tooltip = talent_tooltip
		talent_button.talents_screen = self
	
	talent_tree_container.mouse_entered.connect(on_mouse_entered_or_exited)
	talent_tree_container.mouse_exited.connect(on_mouse_entered_or_exited)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("scroll_down") or event.is_action("scroll_up"):
		if mouse_inside:
			get_viewport().set_input_as_handled()


func on_mouse_entered_or_exited() -> void:
	mouse_inside = not mouse_inside

