extends Node3D

@onready var ability = load("res://resources/abilities/fireblast.tres")
@onready var hitbox: Area3D = $Hitbox
@onready var timer: Timer = $Timer
@onready var visuals: Node3D = $Visuals

var target: CharacterBody3D

var damage: int
var is_crit: bool
var crit_multiplier: float
var crit_damage_stat: float


func _ready() -> void:
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*(crit_damage_stat + 1-crit_multiplier)
	timer.timeout.connect(on_timer_timeout)
	timer.start()
	hitbox.area_entered.connect(on_hitbox_area_entered)
	await get_tree().process_frame
	global_position = target.hit_marker.global_position
	visuals.visible = true
	

func on_hitbox_area_entered(other_area: Area3D) -> void:
	if other_area == target.hurtbox:
		CombatEvents.emit_ability_hit(ability, damage, is_crit, target)
		var pos = other_area.owner.hit_marker.global_position
		CombatEvents.create_floating_combat_text(pos, damage, is_crit)
		target.take_damage(damage)


func on_timer_timeout() -> void:
	queue_free()


