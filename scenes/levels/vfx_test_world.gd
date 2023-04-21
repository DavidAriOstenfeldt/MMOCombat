extends Node3D

@export var ability_cast_to_spawn: PackedScene
@export var ability_to_spawn: PackedScene
@export var targets: Array[NodePath]

@onready var cast_timer: Timer = $CastTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var ability_spawns: Array[Marker3D]
var _targets = []


func _ready() -> void:
	var count = 0
	for marker in get_tree().get_nodes_in_group("ability_spawn"):
		ability_spawns.append(marker)
		_targets.append(get_node(targets[count]))
		count += 1
	
	cast_timer.timeout.connect(on_cast_timer_timeout)
	cooldown_timer.timeout.connect(on_cooldown_timer_timeout)


func on_cast_timer_timeout() -> void:
	if ability_to_spawn == null:
		return
	var count = 0
	for spawn_point in ability_spawns:
		var ability = ability_to_spawn.instantiate()
		var ability_resource = load(ability.ability_resource_path)
		if ability_resource.cast_on_mouse:
			ability.target = _targets[count].global_position
		else:
			ability.target = _targets[count]
		add_child(ability)
		ability.global_position = spawn_point.global_position
		count += 1


func on_cooldown_timer_timeout() -> void:
	if ability_to_spawn == null:
		return
	if cast_timer.is_stopped():
		cast_timer.start()
