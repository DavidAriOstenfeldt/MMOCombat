extends Node3D
class_name ProjectileAbility

@export_file("*.tres") var ability_resource_path
@export var speed = 25
@export var hitbox: Area3D
@export var splash_hitbox: Area3D
@export var visuals: Node3D
@onready var queue_free_timer: Timer = $QueueFreeTimer

var ability: AbilityResource
var target: CharacterBody3D

var damage: int
var is_crit: bool = false
var crit_damage_stat: float
var crit_multiplier: float
var splash_damage: int
var splash_damage_multiplier: float


func _ready() -> void:
	ability = load(ability_resource_path)
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*(crit_damage_stat + 1-crit_multiplier)
	if hitbox != null:
		hitbox.area_entered.connect(on_hitbox_area_entered)
	queue_free_timer.timeout.connect(on_queue_free_timer_timeout)
	
	if splash_hitbox != null:
		splash_hitbox.area_entered.connect(on_splash_hitbox_area_entered)
		@warning_ignore("narrowing_conversion")
		splash_damage = damage * splash_damage_multiplier
	visuals.visible = true


func _process(delta: float) -> void:
	var target_pos = target.hit_marker.global_position
	global_position = global_position.move_toward(target_pos, speed * delta)
	if global_position != target_pos:
		look_at(target_pos)
	
	
func on_queue_free_timer_timeout() -> void:
	queue_free()


func on_hitbox_area_entered(other_area: Area3D) -> void:
	if other_area == target.hurtbox:
		queue_free_timer.start()
		hitbox.get_child(0).set_deferred("disabled", true)
		if splash_hitbox != null:
			splash_hitbox.get_child(0).set_deferred("disabled", false)
		CombatEvents.emit_ability_hit(ability, damage, is_crit, target)
		var pos = other_area.owner.hit_marker.global_position
		CombatEvents.create_floating_combat_text(pos, damage, is_crit)
		target.take_damage(damage)
		visuals.visible = false


func on_splash_hitbox_area_entered(other_area: Area3D) -> void:
	splash_hitbox.get_child(0).set_deferred("disabled", true)
	if other_area == target.hurtbox:
		return
	
	CombatEvents.emit_splash_hit(ability, splash_damage, is_crit, other_area.owner)
	var pos = other_area.owner.hit_marker.global_position
	CombatEvents.create_floating_combat_text(pos, splash_damage, is_crit)
	other_area.owner.take_damage(damage)
