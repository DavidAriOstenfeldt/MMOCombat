extends Node2D

@export var floating_combat_text: PackedScene


@onready var ability = load("res://resources/abilities/fireblast.tres")
@onready var fire_blast: GPUParticles2D = $FireBlast
@onready var hitbox: Area2D = $Hitbox
@onready var fire_hit_particles: Node2D = $FireHitParticles
@onready var timer: Timer = $Timer

var target: CharacterBody2D

var damage: int
var is_crit: bool = true
var crit_multiplier: float = 2.


func _ready() -> void:
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*crit_multiplier
	fire_blast.emitting = true
	timer.timeout.connect(on_timer_timeout)
	timer.wait_time = fire_blast.lifetime
	timer.start()
	hitbox.area_entered.connect(on_hitbox_area_entered)
	await get_tree().process_frame
	global_position = target.global_position - Vector2(0, target.hurtbox.get_child(0).shape.size[1]/2)
	

func on_hitbox_area_entered(other_area: Area2D) -> void:
	if other_area == target.hurtbox:
		var text_inst = floating_combat_text.instantiate()
		text_inst = text_inst as FloatingCombatText
		if is_crit:
			text_inst.text = str(damage) + "!"
			text_inst.to_scale = Vector2(2., 2.)
			text_inst.finish_scale = Vector2(1., 1.)
		else:
			text_inst.text = str(damage)
		text_inst.global_position = target.global_position
		get_parent().add_child(text_inst)
		CombatEvents.emit_ability_hit(ability, damage, is_crit, target)
		


func on_timer_timeout() -> void:
	queue_free()
