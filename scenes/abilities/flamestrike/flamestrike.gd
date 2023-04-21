extends Node3D

@onready var ability = load("res://resources/abilities/flamestrike.tres")
@onready var hitbox: Area3D = $Hitbox
@onready var timer: Timer = $Timer
@onready var visuals: Node3D = $Visuals

var target: Vector3

var damage: int
var is_crit: bool = false
var crit_multiplier: float
var crit_damage_stat: float


func _ready() -> void:
	await get_tree().process_frame
	global_position = target
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage* (crit_damage_stat + 1-crit_multiplier)
	timer.timeout.connect(on_timer_timeout)
	timer.start()
	hitbox.area_entered.connect(on_hitbox_area_entered)
	hitbox.get_child(0).disabled = false
	visuals.visible = true
#	var tween = get_tree().create_tween()
#	tween.set_ease(Tween.EASE_IN)
#	tween.set_trans(Tween.TRANS_EXPO)
#	tween.chain()
#	tween.tween_property(visuals.get_child(0), "transparency", 0., .125).from(1)
#	tween.set_ease(Tween.EASE_IN)
#	tween.set_trans(Tween.TRANS_SINE)
#	tween.tween_property(visuals.get_child(0), "transparency", 1., .125).from(0)
	await get_tree().create_timer(.25).timeout
	hitbox.get_child(0).disabled = true
	

func on_hitbox_area_entered(other_area: Area3D) -> void:
	var _target = other_area.get_parent()
	CombatEvents.emit_ability_hit(ability, damage, is_crit, _target)
	CombatEvents.create_floating_combat_text(target, damage, is_crit)
	other_area.owner.take_damage(damage)


func on_timer_timeout() -> void:
	queue_free()
