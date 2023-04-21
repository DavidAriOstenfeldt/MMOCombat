extends CharacterBody2D
class_name Player

@export var stats: PlayerStats

@onready var global_cooldown_timer = $GlobalCooldownTimer
@onready var cast_timer = $CastTimer
@onready var abilty_spawn_position: Marker2D = $AbiltySpawnPosition
@onready var buffs: Node = $Buffs
@onready var passives: Node = $Passives
@onready var talent_screen: CanvasLayer = $TalentScreen
@onready var ability_parent = $Abilities

var abilities: Array[AbilityController]
var spell_queue = Queue.new()

var target: CharacterBody2D = null
var target_at_cast_time: CharacterBody2D = null
var cast_while_casting_target: CharacterBody2D = null
var mouse_position_at_cast_time: Vector2

var is_casting: bool = false
var casting_ability: AbilityResource
var cast_while_casting_ability: AbilityResource


func _ready():
	randomize()
	cast_timer.timeout.connect(on_cast_timer_timeout)
	global_cooldown_timer.timeout.connect(on_global_cooldown_timer_timeout)
	await get_tree().create_timer(0.1).timeout
	update_abilities()
	add_child(spell_queue)
	GameEvents.ability_button_pressed.connect(ability_pressed)


func update_abilities() -> void:
	abilities = []
	for child in ability_parent.get_children():
		abilities.append(child)
	
	GameEvents.emit_abilities_updated(abilities)


func _input(event):

	if not event is InputEventKey:
		return
	
	if event.is_action_pressed("cancel"):
		if talent_screen.visible:
			talent_screen.visible = false
		cancel_cast()
		
	
	if event.is_action_pressed("talent_screen"):
		talent_screen.visible = !talent_screen.visible
		
#	var event_text = str(event.as_text())
#	if not InputMap.has_action("ability_" + event_text):
#		return
#
#
#	if event.is_action_pressed("ability_" + event_text):
#		ability_pressed(int(event_text))
		
	


func ability_pressed(ability_number: int) -> void:
	if ability_number == 0: ability_number = 10
	ability_number = ability_number - 1
	if abilities.size() - 1 >= ability_number:
		if is_cast_available(ability_number):
			start_casting_ability(ability_number)
	else:
		print("No ability assigned to slot ", str(ability_number + 1))


# TODO: Actually give error messages to the user instead of pritns
func is_cast_available(ability_number: int) -> bool:
	var ability_controller = abilities[ability_number] as AbilityController
	if target == null and not ability_controller.ability.cast_on_mouse:
		print("no target")
		return false
	if global_cooldown_timer.time_left > 0.0:
		if ability_controller.ability.castable_while_casting and ability_controller.charges_left > 0:
			return true
		spell_queue.add_to_queue(ability_number)
		print("global cooldown")
		return false
	if is_casting:
		if ability_controller.ability.castable_while_casting and ability_controller.charges_left > 0:
			cast_while_casting_ability = ability_controller.ability
			return true
		else:
			spell_queue.add_to_queue(ability_number)
			print("already casting")
			return false
	if ability_controller.ability.charges > 1 and ability_controller.charges_left > 0:
#		print("%d charges left" % (ability_controller.charges_left -1))
		return true
	if ability_controller.ability_cooldown_timer.time_left > 0.0:
		print("ability on cooldown")
		return false
	else:
		return true


func start_casting_ability(ability_number: int) -> void:
	var ability_controller = abilities[ability_number]
	var ability = get_modified_ability(ability_controller.ability)
	if is_casting:
		cast_while_casting_target = target
		cast_while_casting_ability = ability
		start_global_cooldown(0.25)
	elif ability.castable_while_casting:
		cast_while_casting_target = target
		casting_ability = ability
		start_global_cooldown(0.25)
	else:
		mouse_position_at_cast_time = get_viewport().get_mouse_position()
		target_at_cast_time = target
		casting_ability = ability
		start_global_cooldown()
	ability_controller.charges_left -= 1
	if ability.cast_time > 0.0:
		start_cast_timer(ability_number)
#		print("starting cast of ", ability.name, " at ", target_at_cast_time)
	else:
		CombatEvents.emit_cast_started(0.0, ability_number, ability.cooldown / stats.get_haste_percent(), ability)
		if ability.cast_on_mouse:
			var _target = get_viewport().get_mouse_position()
			spawn_ability(_target)
		else:
			spawn_ability(target)
#		print("cast ", ability.name, " at ", target_at_cast_time)
		
	var ability_cooldown_timer = ability_controller.ability_cooldown_timer
	if ability.charges > 1 and ability_cooldown_timer.time_left > 0.0:
		return
	if ability.cooldown > 0.0:
		ability_cooldown_timer.wait_time = ability.cooldown / stats.get_haste_percent()
		ability_cooldown_timer.start()
	

func start_global_cooldown(time: float = stats.get_global_cooldown()) -> void:
	global_cooldown_timer.wait_time = time
	CombatEvents.emit_global_cooldown_started(global_cooldown_timer.wait_time)
	global_cooldown_timer.start()
	

func start_cast_timer(ability_number: int) -> void:
	var ability = abilities[ability_number].ability
	is_casting = true
	cast_timer.wait_time = ability.cast_time / stats.get_haste_percent()
	CombatEvents.emit_cast_started(cast_timer.wait_time, ability_number, ability.cooldown / stats.get_haste_percent(), ability)
	cast_timer.start()


func spawn_ability(_target) -> void:
	if cast_while_casting_ability == null:
		if casting_ability.ability_scene != null:
			var cast = casting_ability.ability_scene.instantiate()
			@warning_ignore("narrowing_conversion")
			cast.damage = randi_range(casting_ability.damage*0.95, casting_ability.damage*1.05)
			if randf() < stats.get_crit_percent() + casting_ability.additional_crit_chance:
				cast.is_crit = true
				cast.crit_multiplier = stats.crit_multiplier
			cast.global_position = abilty_spawn_position.global_position 
			cast.target = _target
			get_parent().add_child(cast)
			is_casting = false
			CombatEvents.emit_cast_finished(casting_ability)
	else:
		if cast_while_casting_ability.ability_scene != null:
			var cast = cast_while_casting_ability.ability_scene.instantiate()
			cast.damage = floor(randf_range(cast_while_casting_ability.damage*0.95, cast_while_casting_ability.damage*1.05))
			if randf() < stats.get_crit_percent():
				cast.is_crit = true
				cast.crit_multiplier = stats.crit_multiplier
			cast.global_position = abilty_spawn_position.global_position
			cast.target = _target
			get_parent().add_child(cast)
			CombatEvents.emit_cast_finished(cast_while_casting_ability)
			cast_while_casting_ability = null
	

# Modify ability with buff/passive modifiers
func get_modified_ability(ability: AbilityResource) -> AbilityResource:
	var modified_ability = ability.duplicate(true) as AbilityResource
	var buff_modifiers = get_buff_modifiers()
	for _buff in buff_modifiers:
		var buff = buff_modifiers[_buff]
		var shared_element = false
		if buff.has("element_condition"):
			shared_element = has_shared_element(ability.elements.type, buff.element_condition.type)
		if (buff.has("modifies_ability") and buff.modifies_ability == ability) or shared_element:
			var ability_stats = buff.ability_stat_modifier.stat
			# Apply flat amounts first
			for stat_name in ability_stats:
				var stat = ability_stats[stat_name]
				if stat != true:
					continue
				if not buff.has("flat_amount"):
					continue
				if stat_name == "Crit Chance":
					if buff.flat_amount != 0.:
						modified_ability.additional_crit_chance += buff.flat_amount
				if stat_name == "Damage":
					if buff.flat_amount != 0.:
						modified_ability.damage += buff.flat_amount
				if stat_name == "Cooldown":
					if buff.flat_amount != 0.:
						modified_ability.cooldown -= buff.flat_amount
						modified_ability.cooldown = max(modified_ability.cooldown, 0.0)
				if stat_name == "Cast Time":
					if buff.flat_amount != 0.:
						modified_ability.cast_time -= buff.flat_amount
						modified_ability.cast_time = max(modified_ability.cast_time, 0.0)
						if modified_ability.cast_time == 0.0:
							modified_ability.cast_type = "Instant"
				
			# Apply percent amounts second
			for stat_name in ability_stats:
				var stat = ability_stats[stat_name]
				if stat != true:
					continue
				if not buff.has("perc_amount"):
					continue
				if buff.has("current_stacks"):
					buff.perc_amount *= buff.current_stacks
				if stat_name == "Crit Chance":
					if buff.perc_amount != 0.:
						modified_ability.additional_crit_chance += buff.perc_amount * buff.rank
				if stat_name == "Damage":
					if buff.perc_amount != 0.:
						modified_ability.damage = modified_ability.damage * (1 + buff.perc_amount  * buff.rank)
				if stat_name == "Cooldown":
					if buff.perc_amount != 0.:
						modified_ability.cooldown = modified_ability.cooldown * (1 - buff.perc_amount  * buff.rank)
						modified_ability.cooldown = max(modified_ability.cooldown, 0.0)
				if stat_name == "Cast Time":
					if buff.perc_amount != 0.:
						modified_ability.cast_time = modified_ability.cast_time *  (1 - buff.perc_amount  * buff.rank)
						modified_ability.cast_time = max(modified_ability.cast_time, 0.0)
						if modified_ability.cast_time == 0.0:
							modified_ability.cast_type = "Instant"
	return modified_ability


func get_buff_modifiers() -> Dictionary:
	var buff_modifiers: Dictionary = {}
	var buff_children = buffs.get_children()
	# Loop over all buffs and add their modifiers to buff_aray
	for buff in buff_children:
		buff = buff.buff_resource as BuffResource
		buff_modifiers[buff.id] = {}
		if buff.modifies_ability != null:
			buff_modifiers[buff.id]["modifies_ability"] = buff.modifies_ability
		if buff.ability_stat_modifiers != null:
			buff_modifiers[buff.id]["ability_stat_modifier"] = buff.ability_stat_modifiers
		if buff.modifies_player != null:
			buff_modifiers[buff.id]["modifies_player"] = buff.modifies_player
		if buff.player_stat_modifiers != null:
			buff_modifiers[buff.id]["player_stat_modifier"] = buff.player_stat_modifiers
		if buff.flat_amount != 0:
			if buff.debuff:
				buff_modifiers[buff.id]["flat_amount"] = -buff.flat_amount
			else:
				buff_modifiers[buff.id]["flat_amount"] = buff.flat_amount
		if buff.perc_amount != 0:
			if buff.debuff:
				buff_modifiers[buff.id]["perc_amount"] = -buff.perc_amount
			else:
				buff_modifiers[buff.id]["perc_amount"] = buff.perc_amount
		if buff.element_condition != null:
			buff_modifiers[buff.id]["element_condition"] = buff.element_condition
		if buff.unit_type_condition != null:
			buff_modifiers[buff.id]["unit_type_condition"] = buff.unit_type_condition
		if buff.stacks:
			buff_modifiers[buff.id]["current_stacks"] = buff.current_stacks
		buff_modifiers[buff.id]["rank"] = buff.rank
		
	return buff_modifiers


func has_shared_element(ability_elements: Dictionary, buff_elements: Dictionary) -> bool:
	for element in ability_elements.keys():
		if ability_elements[element] and buff_elements[element]:
			return true
	return false


func cancel_cast() -> void:
	cast_timer.stop()
	is_casting = false
	CombatEvents.emit_cast_cancelled()
	


func on_cast_timer_timeout() -> void:
	if cast_while_casting_ability != null:
		spawn_ability(cast_while_casting_target)
	else:
		if casting_ability.cast_on_mouse:
			spawn_ability(mouse_position_at_cast_time)
		else:
			spawn_ability(target_at_cast_time)
#	print("finished casting ", casting_ability.name)
	if spell_queue.get_size() > 0:
		var spell = spell_queue.get_next()
		if is_cast_available(spell):
			start_casting_ability(spell)
		

func on_global_cooldown_timer_timeout() -> void:
	if spell_queue.get_size() >0:
		var spell = spell_queue.get_next()
		if is_cast_available(spell):
			start_casting_ability(spell)
	
