extends Node

@export var passive_resource: PassiveResource
@export var buff_scene: PackedScene

var buff_instance: Buff = null
var buff_resource: BuffResource

func _ready() -> void:
	CombatEvents.ability_hit.connect(on_ability_hit)


func on_ability_hit(ability: AbilityResource, damage: int, is_crit: bool) -> void:
	if ability.id != "fireball":
		return
	
	# If we have the buff
	if buff_instance != null:
		# If we crit
		if is_crit:
			buff_instance.on_remove()
			buff_instance = null
		# If we don't crit
		else:
			buff_resource.current_stacks += 1
			if buff_resource.max_stacks > 0:
				buff_resource.current_stacks = min(buff_resource.current_stacks, buff_resource.max_stacks)
	# If we don't have the buff and is crit
	elif not is_crit:
		var par_buffs = get_parent().get_parent().buffs
		buff_instance = buff_scene.instantiate()
		buff_instance.buff_resource.rank = passive_resource.rank
		buff_resource = buff_instance.buff_resource
		par_buffs.add_child(buff_instance)
	
func _exit_tree() -> void:
	if buff_instance != null:
		CombatEvents.emit_buff_lost(buff_resource)
