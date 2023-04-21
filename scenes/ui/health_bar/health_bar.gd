extends Sprite3D

@onready var label: Label3D = $Label3D
@onready var health_bar = $SubViewport/HealthBar
@onready var health_change_bar = $SubViewport/HealthChanged
@export var tint: Color

var highlighted: bool = false

func _ready():
	texture = $SubViewport.get_texture()
	health_bar.tint_progress = tint
	var par = owner
	par.health_updated.connect(_on_health_updated)
	par.max_health_updated.connect(_on_max_health_updated)
	health_change_bar.value = health_bar.value
	health_change_bar.max_value = health_bar.max_value
	health_change_bar.size = health_bar.size
	await get_tree().process_frame
	label.text = owner.npc_name
	transparency = .5
	label.transparency = .5

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if owner != null and (owner.hovering or player.target == owner):
		if not highlighted:
			highlighted = true
			health_bar.tint_over = Color("ff9505")
			render_priority = 5
			label.render_priority = 5
			label.outline_render_priority = label.render_priority-1
			transparency = 0.
			label.transparency = 0.
			label.outline_modulate = Color("ff9505")
			@warning_ignore("narrowing_conversion")
			label.outline_size = label.outline_size * 0.1

	else:
		if highlighted:
			highlighted = false
			health_bar.tint_over = Color("191919")
			render_priority = 0
			label.render_priority = 0
			label.outline_render_priority = label.render_priority-1
			transparency = .5
			label.transparency = .5
			label.outline_modulate = Color("000000")
			@warning_ignore("narrowing_conversion")
			label.outline_size = label.outline_size*10


func _on_health_updated(new_health: int):
	health_bar.value = new_health
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(health_change_bar, "value", new_health, 0.5).set_delay(.25)
	if new_health == health_change_bar.value:
		health_change_bar.value = new_health
	
func _on_max_health_updated(new_health: int):
	health_bar.max_value = new_health
	health_change_bar.max_value = new_health
	
