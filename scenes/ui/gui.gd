extends CanvasLayer
class_name GUI

@export var buff_scene: PackedScene

@onready var buff_container: HBoxContainer = %BuffContainer
@onready var debuff_container: HBoxContainer = %DebuffContainer
@onready var buff_tooltip: PanelContainer = %BuffTooltip
@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	CombatEvents.buff_aplied.connect(on_buff_applied)
	await get_tree().process_frame
	if get_tree().get_first_node_in_group("player") == null:
		queue_free()


func _unhandled_key_input(event: InputEvent) -> void:
	if not pause_menu.visible and not pause_menu.settings_menu.visible:
		if event.is_action_pressed("cancel"):
			pause_menu.visible = true
			get_viewport().set_input_as_handled()


func on_buff_applied(buff: BuffResource) -> void:
	var buff_inst = buff_scene.instantiate()
	buff_inst.buff_resource = buff
	buff_inst.buff_tooltip = buff_tooltip
	if buff.debuff:
		debuff_container.add_child(buff_inst)
	else:
		buff_container.add_child(buff_inst)


