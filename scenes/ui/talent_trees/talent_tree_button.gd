extends Button
class_name TalentTreeButton

@onready var talent_point_label: Label = %TalentPointLabel
@onready var rank_label: Label = $RankLabel
@export var talent_resource: TalentResource
@export var scene: PackedScene
var instance = null
var tooltip: TalentTooltip

var talents_screen: CanvasLayer
var talent_points_left: int


func _ready() -> void:
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	await get_tree().process_frame
	if talent_resource != null:
		update_button_visuals()


func update_button_visuals() -> void:
	icon = talent_resource.icon
	rank_label.text = "%d/%d" % [talent_resource.current_rank, talent_resource.max_rank]
	talent_point_label.text = "%d talent points available" % talent_points_left


func on_gui_input(event: InputEvent) -> void:
	if talent_resource == null:
		return
	if event is InputEventMouseButton:
		talent_points_left = talents_screen.talent_points_left
		if event.is_action_pressed("ui_left_click") and talent_points_left > 0 and talent_resource.current_rank < talent_resource.max_rank:
			talent_resource.current_rank += 1
			talent_resource.current_rank = clamp(talent_resource.current_rank, 0, talent_resource.max_rank)
			talent_resource.resource.rank = talent_resource.current_rank
			if talent_resource.passive:
				add_passive()
			talents_screen.talent_points_left -= 1
			talents_screen.talent_points_spent += 1
		elif event.is_action_pressed("ui_right_click") and talent_resource.current_rank > 0:
			talent_resource.current_rank -= 1
			talent_resource.current_rank = clamp(talent_resource.current_rank, 0, talent_resource.max_rank)
			talent_resource.resource.rank = talent_resource.current_rank
			if talent_resource.passive:
				remove_passive()
			talents_screen.talent_points_left += 1
			talents_screen.talent_points_spent -= 1
	
	
	tooltip.update_tooltip(talent_resource.resource)
	update_button_visuals()


func add_passive() -> void:
	if instance == null:
		instance = scene.instantiate()
		var player = get_tree().get_first_node_in_group("player")
		player.get_node("Passives").add_child(instance)
		instance.passive_resource = talent_resource.resource
	else:
		instance.passive_resource = talent_resource.resource


func remove_passive() -> void:
	if instance != null:
		if talent_resource.current_rank == 0:
			instance.queue_free()
			instance = null


func on_mouse_entered() -> void:
	if tooltip != null:
		if talent_resource != null:
			tooltip.update_tooltip(talent_resource.resource)
		else:
			tooltip.update_tooltip_nyi(talent_resource)
		tooltip.position = Vector2(510, 100)
		tooltip.show()


func on_mouse_exited() -> void:
	if tooltip != null:
		tooltip.reset_tooltip()
		tooltip.hide()
