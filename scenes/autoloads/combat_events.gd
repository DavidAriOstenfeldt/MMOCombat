extends Node

signal cast_started(cast_time: float, ability_number: int, ability_cooldown: float, ability: AbilityResource)
signal cast_cancelled
signal global_cooldown_started(global_cooldown: float)
signal cast_finished(ability: AbilityResource)
signal ability_hit(ability: AbilityResource, damage: int, is_crit: bool)
signal splash_hit(ability: AbilityResource, damage: int, is_crit: bool)
signal buff_aplied(buff: BuffResource)
signal buff_lost(buff: BuffResource)

@export var print_combat_events: bool = true
var floating_combat_text_scene = preload("res://scenes/ui/floating_combat_text/floating_combat_text.tscn")


func emit_cast_finished(ability: AbilityResource) -> void:
	cast_finished.emit(ability)
	if print_combat_events:
		print("%s cast finished." % ability.name)

# remember to add target: CharacterBody3D
func emit_ability_hit(ability: AbilityResource, damage: int, is_crit: bool, target) -> void:
	ability_hit.emit(ability, damage, is_crit)
	if print_combat_events:
		if not is_crit:
			print("%s hit %s for %d %s damage." % [ability.name, target, damage, (Utils.get_elements_string(ability)).to_lower()])
		else:
			print("%s crit %s for %d %s damage!" % [ability.name, target, damage, (Utils.get_elements_string(ability)).to_lower()])


func emit_cast_started(cast_time: float, ability_number: int, ability_cooldown: float, ability: AbilityResource = null) -> void:
	emit_signal("cast_started", cast_time, ability_number, ability_cooldown, ability)
	

func emit_global_cooldown_started(global_cooldown: float) -> void:
	emit_signal("global_cooldown_started", global_cooldown)

# remember to add target: CharacterBody3D
func emit_splash_hit(ability: AbilityResource, damage: int, is_crit: bool, target) -> void:
	splash_hit.emit(ability, damage, is_crit)
	if print_combat_events:
		if not is_crit:
			print("%s splash hit %s for %d %s damage." % [ability.name, target, damage, (Utils.get_elements_string(ability)).to_lower()])
		else:
			print("%s splash crit %s for %d %s damage!" % [ability.name, target, damage, (Utils.get_elements_string(ability)).to_lower()])


func emit_buff_applied(buff: BuffResource) -> void:
	buff_aplied.emit(buff)
	if print_combat_events:
		print("Gained %s" % buff.name)


func emit_buff_lost(buff: BuffResource) -> void:
	buff_lost.emit(buff)
	if print_combat_events:
		print("Lost %s" % buff.name)


func emit_cast_cancelled() -> void:
	cast_cancelled.emit()
	if print_combat_events:
		print("Cancelled cast")


func create_floating_combat_text(position: Vector3, amount: int = 0, is_crit: bool = false) -> void:
	var entity_layer = get_tree().get_first_node_in_group("entity_layer")
	if entity_layer == null:
		return
	var text = floating_combat_text_scene.instantiate()
	text.text = str(amount)
	text.is_crit = is_crit
	entity_layer.add_child(text)
	text.global_position = position + Vector3.RIGHT.rotated(Vector3.UP, randf_range(0, TAU)) * randf_range(1, 2)
