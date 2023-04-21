extends Node2D

@export var hit_particles: PackedScene
@export var floating_combat_text: PackedScene

@onready var ability = load("res://resources/abilities/phoenix_flames.tres")
@onready var hitbox: Area2D = $Hitbox
@onready var queue_free_timer: Timer = $QueueFreeTimer
@onready var sparks: GPUParticles2D = $Sparks
@onready var stars: GPUParticles2D = $Stars
@onready var visuals: Node2D = $Visuals
@onready var phoenix: Sprite2D = $Visuals/Phoenix
@onready var twirl: Sprite2D = $Visuals/Twirl
@onready var aoe_hitbox: Area2D = $AoeHitbox

var speed = 700.
var height = 100.

var start_pos: Vector2
var end_pos: Vector2
var current_pos: Vector2
var distance: float
var current_time: float = 0
var max_time: float
var offset: Vector2 =  Vector2(0, 32)


var target: CharacterBody2D

var damage: int
var aoe_damage: int
var aoe_damage_multiplier: float = .75
var is_crit: bool = true
var crit_multiplier: float = 2


func _ready() -> void:
	start_pos = global_position
	end_pos = target.global_position - offset
	distance = start_pos.distance_to(end_pos)
	max_time = distance / speed
	
	if is_crit:
		@warning_ignore("narrowing_conversion")
		damage = damage*crit_multiplier
	hitbox.area_entered.connect(on_hitbox_area_entered)
	aoe_hitbox.area_entered.connect(on_aoe_hitbox_area_entered)
	queue_free_timer.timeout.connect(on_queue_free_timer_timeout)
	@warning_ignore("narrowing_conversion")
	aoe_damage = damage * aoe_damage_multiplier
	

func _process(delta: float) -> void:
	current_time += delta
	end_pos = target.global_position - offset
	var t = current_time/max_time
	var parabolic_height = -height * 4 * t * (t - 1)
	current_pos = start_pos.lerp(end_pos, t) - Vector2(0, parabolic_height)

	global_position = global_position.move_toward(current_pos, speed * delta)
	
	visuals.rotation_degrees += 400 * delta
	
	
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
		sparks.emitting = false
		stars.emitting = false
		phoenix.visible = false
		twirl.visible = false
		#queue_free_timer.wait_time = fireball.lifetime
		queue_free_timer.start()
		global_position = target.global_position + Vector2.UP * 24
		hitbox.get_child(0).set_deferred("disabled", true)
		aoe_hitbox.get_child(0).set_deferred("disabled", false)
		CombatEvents.emit_ability_hit(ability, damage, is_crit, target)


func on_aoe_hitbox_area_entered(other_area: Area2D) -> void:
	aoe_hitbox.get_child(0).set_deferred("disabled", true)
	if other_area == target.hurtbox:
		return
	var text_inst = floating_combat_text.instantiate()
	text_inst = text_inst as FloatingCombatText
	if is_crit:
		text_inst.text = str(aoe_damage) + "!"
		text_inst.to_scale = Vector2(2., 2.)
		text_inst.finish_scale = Vector2(1., 1.)
	else:
		text_inst.text = str(aoe_damage)
	text_inst.global_position = other_area.owner.global_position
	get_parent().add_child(text_inst)
	
	var hit_ins = hit_particles.instantiate()
	hit_ins.global_position = global_position
	get_parent().add_child(hit_ins)
	
	# TODO: REMOVE FROM HERE AND ADD A take_damage() function to enemy
	var other_parent = other_area.owner
	if other_parent.animation_player.is_playing():
		other_parent.animation_player.stop()
	other_parent.animation_player.play("hurt")
	CombatEvents.emit_splash_hit(ability, aoe_damage, is_crit, target)
