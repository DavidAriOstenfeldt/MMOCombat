extends CharacterBody3D

@onready var hurtbox = $Hurtbox
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hit_marker: Node3D = $Visuals/HitMarker
@onready var body = $Visuals/MeshInstance3D
@onready var heal_timer: Timer = $HealTimer
@onready var health_bar: Sprite3D = $HealthBar


var hovering: bool = false

var npc_name = "Target Dummy"
var health = 500
var max_health = health
var healing = false

signal health_updated(new_health: int)
signal max_health_updated(new_health: int)


func _ready() -> void:
	heal_timer.timeout.connect(on_heal_timer_timeout)
	emit_signal("max_health_updated", max_health)
	emit_signal("health_updated", health)
	await get_tree().process_frame
	if player == null:
		health_bar.queue_free()
	


func _physics_process(delta: float) -> void:
	if healing:
		heal(1)


func on_input_event(camera: Node, event: InputEvent, _position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if player == null:
		return
	if event.is_action_pressed("click_target"):
		player.target = self


func on_mouse_entered() -> void:
	if player == null:
		return
	hovering = true
	body.material_overlay.set("shader_parameter/enabled", true)


func on_mouse_exited() -> void:
	hovering = false
	if player == null:
		return
	if player.target != self:
		body.material_overlay.set("shader_parameter/enabled", false)


func take_damage(amount: int) -> void:
	healing = false
	heal_timer.stop()
	heal_timer.start()
	health -= amount
	health = clamp(health, 1, max_health)
	emit_signal("health_updated", health)


func heal(amount: int) -> void:
	health += amount
	health = clamp(health, 1, max_health)
	emit_signal("health_updated", health)


func on_heal_timer_timeout() -> void:
	healing = true
