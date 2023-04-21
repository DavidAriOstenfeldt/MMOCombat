extends Node2D

@export var particle: PackedScene

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	

func on_timer_timeout() -> void:
	var particle_instance = particle.instantiate()
	particle_instance.global_position = global_position
	particle_instance.target = get_tree().get_first_node_in_group("enemy")
	get_parent().add_child(particle_instance)
