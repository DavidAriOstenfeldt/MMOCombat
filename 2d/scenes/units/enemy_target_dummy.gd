extends CharacterBody2D

@onready var hurtbox = $Hurtbox
@onready var body = $Visuals/Body
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var hovering: bool = false


func _ready():
	body.material.set("shader_parameter/on", false)
	hurtbox.area_entered.connect(on_hurtbox_area_entered)
	animation_player.animation_finished.connect(on_animation_finished)


func _unhandled_input(event):
	if event.is_action_pressed("click_target"):
		if hovering:
			player.target = self
		else:
			body.material.set("shader_parameter/on", false)
			# check if we're not hovering over anyone else
			var enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies:
				if enemy.hovering:
					return
			player.target = null
			

func on_mouse_entered():
	hovering = true
	body.material.set("shader_parameter/on", true)


func on_mouse_exited():
	hovering = false
	if player.target != self:
		body.material.set("shader_parameter/on", false)


func on_hurtbox_area_entered(other_area: Area2D) -> void:
	if other_area.owner.target is CharacterBody2D and other_area.owner.target != self:
		return
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("hurt")
	

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "hurt":
		animation_player.play("idle")
