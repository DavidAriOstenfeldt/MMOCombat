extends Node2D

@export var hit_particles: PackedScene
@export var floating_combat_text: PackedScene

@onready var ability = load("res://resources/abilities/fireball.tres")
@onready var hitbox: Area2D = $Hitbox
@onready var queue_free_timer: Timer = $QueueFreeTimer
@onready var fireball: GPUParticles2D = $Fireball
@onready var smoke: GPUParticles2D = $Smoke
@onready var sparks: GPUParticles2D = $Sparks

var speed = 800

var target: CharacterBody2D

var damage: int
var is_crit: bool = false
var crit_multiplier: float = 2.

func _ready() -> void:
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*crit_multiplier
	hitbox.area_entered.connect(on_hitbox_area_entered)
	queue_free_timer.timeout.connect(on_queue_free_timer_timeout)
	

func _process(delta: float) -> void:
	var target_pos = target.position + Vector2.UP * 32
	global_position = global_position.move_toward(target_pos, speed * delta)
	var dir = (target_pos - global_position).normalized()
	rotation = dir.angle()
	
	
func on_queue_free_timer_timeout() -> void:
	queue_free()


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
		
		var hit_ins = hit_particles.instantiate()
		hit_ins.global_position = global_position
		get_parent().add_child(hit_ins)
		speed = 0.
		fireball.emitting = false
		fireball.visible = false
		sparks.emitting = false
		smoke.emitting = false
		queue_free_timer.wait_time = fireball.lifetime
		queue_free_timer.start()
		hitbox.get_child(0).set_deferred("disabled", true)
		CombatEvents.emit_ability_hit(ability, damage, is_crit, target)
