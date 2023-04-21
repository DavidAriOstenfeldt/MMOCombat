extends Node2D

@export var floating_combat_text: PackedScene


@onready var ability = load("res://resources/abilities/flamestrike.tres")
@onready var flamestrike: GPUParticles2D = $FlameStrike
@onready var hitbox: Area2D = $Hitbox
@onready var fire_hit_particles: Node2D = $FireHitParticles
@onready var timer: Timer = $Timer
@onready var visuals: Node2D = $Visuals

var target: Vector2

var damage: int
var is_crit: bool = false
var crit_multiplier: float = 2.


func _ready() -> void:
	await get_tree().process_frame
	global_position = target
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*crit_multiplier
	flamestrike.emitting = true
	timer.timeout.connect(on_timer_timeout)
	timer.wait_time = flamestrike.lifetime
	timer.start()
	hitbox.area_entered.connect(on_hitbox_area_entered)
	hitbox.get_child(0).disabled = false
	visuals.visible = true
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.chain()
	tween.tween_property(visuals, "modulate:a", 1., .125)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(visuals, "modulate:a", 0., .125)
	await get_tree().create_timer(.25).timeout
	hitbox.get_child(0).disabled = true
	

func on_hitbox_area_entered(other_area: Area2D) -> void:
	var _target = other_area.get_parent()
	var text_inst = floating_combat_text.instantiate()
	text_inst = text_inst as FloatingCombatText
	if is_crit:
		text_inst.text = str(damage) + "!"
		text_inst.to_scale = Vector2(2., 2.)
		text_inst.finish_scale = Vector2(1., 1.)
	else:
		text_inst.text = str(damage)
	text_inst.global_position = _target.global_position
	get_parent().add_child(text_inst)
	CombatEvents.emit_ability_hit(ability, damage, is_crit, _target)
	
		


func on_timer_timeout() -> void:
	queue_free()
