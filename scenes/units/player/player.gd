extends CharacterBody3D

@export var stats: PlayerStats

@onready var spring_arm_pivot: Node3D = $SpringArmPivot
@onready var spring_arm: SpringArm3D = $SpringArmPivot/SpringArm3D
@onready var camera_3d: Camera3D = $SpringArmPivot/SpringArm3D/Camera3D
@onready var visuals: Node3D = $Visuals
@onready var hover_timer: Timer = $HoverTimer
@onready var target_timer: Timer = $TargetTimer

@onready var global_cooldown_timer = $GlobalCooldownTimer
@onready var cast_timer = $CastTimer
@onready var buffs: Node = $Buffs
@onready var passives: Node = $Passives
@onready var talent_screen: CanvasLayer = $TalentScreen
@onready var ability_parent = $Abilities
@onready var ability_spawn_position: Node3D = $Visuals/AbilitySpawnPosition

var max_move_speed = 5
var walk_speed = 2.5
var jump_velocity = 6

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 19.6

var mouse_release_action: String = ""
var mouse_pressed = false
var mouse_position_on_capture: Vector2
var zoom_speed = 2

var abilities: Array[AbilityController]
var spell_queue = Queue.new()

var target: CharacterBody3D = null
var target_at_cast_time: CharacterBody3D = null
var cast_while_casting_target: CharacterBody3D = null
var mouse_position_at_cast_time

var is_casting: bool = false
var casting_ability: AbilityResource
var cast_while_casting_ability: AbilityResource


func _ready():
	randomize()
	cast_timer.timeout.connect(on_cast_timer_timeout)
	global_cooldown_timer.timeout.connect(on_global_cooldown_timer_timeout)
	hover_timer.timeout.connect(on_hover_timer_timeout)
	target_timer.timeout.connect(on_target_timer_timeout)
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
		if talent_screen.visible and not is_casting:
			talent_screen.visible = false
			get_viewport().set_input_as_handled()
		if is_casting:
			cancel_cast()
			get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("talent_screen"):
		talent_screen.visible = !talent_screen.visible
		talent_screen.talent_points_total = stats.talent_points_available
		if talent_screen.talent_points_left == null:
			talent_screen.talent_points_left = stats.talent_points_available


func _unhandled_input(event: InputEvent) -> void:
#	if Input.is_action_just_pressed("cancel") and not talent_screen.visible:
#		get_tree().quit()
	
	if event.is_action_pressed("ui_right_click") or event.is_action_pressed("ui_left_click"):
		if not mouse_pressed:
			mouse_position_on_capture = event.position
		if event.is_action_pressed("ui_right_click") and not mouse_pressed:
			mouse_release_action = "ui_right_click"
			mouse_pressed = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed("ui_left_click") and not mouse_pressed:
			hover_timer.start()
			target_timer.start()

	if mouse_pressed and event.is_action_released(mouse_release_action):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_pressed = false
		await get_tree().process_frame
		Input.warp_mouse(mouse_position_on_capture)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		spring_arm_pivot.rotate_y(-event.relative.x * .005)
		spring_arm.rotate_x(-event.relative.y * .005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2, PI/2)
	
	if event is InputEventMouse:
		if event.is_action_pressed("scroll_down") or event.is_action_pressed("scroll_up"):
			var scroll_tween = get_tree().create_tween()
			scroll_tween.set_ease(Tween.EASE_IN_OUT)
			scroll_tween.set_trans(Tween.TRANS_CUBIC)
			var scroll_target
			if event.is_action_pressed("scroll_up"):
				scroll_target = spring_arm.spring_length+zoom_speed
			if event.is_action_pressed("scroll_down"):
				scroll_target = spring_arm.spring_length-zoom_speed
			scroll_tween.tween_property(spring_arm, "spring_length", clamp(scroll_target, 0, 12), .25)
		
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_pressed("ui_right_click"):
		visuals.rotation.y = spring_arm_pivot.rotation.y
		
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	if Input.is_action_pressed("ui_left_click") and Input.is_action_pressed("ui_right_click"):
		input_dir = Vector2(0, -1)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, visuals.rotation.y)
	var move_speed: float = max_move_speed
	# If walking backwards
	if input_dir.y > 0:
		move_speed = walk_speed
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
	
	if casting_ability == null:
		return
	if not input_dir.is_zero_approx() and is_casting and not casting_ability.cast_while_moving:
		cancel_cast()


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
	var ability = get_modified_ability(ability_controller.ability)
	if target == null and not ability.cast_on_mouse:
		if CombatEvents.print_combat_events: print("no target")
		return false
	if not velocity.is_zero_approx() and not ability.cast_while_moving and not ability.cast_time == 0.:
		if CombatEvents.print_combat_events: print("can't cast while moving")
		return false
	if global_cooldown_timer.time_left > 0.0:
		if ability.castable_while_casting and ability_controller.charges_left > 0:
			return true
		spell_queue.add_to_queue(ability_number)
		if CombatEvents.print_combat_events: print("global cooldown")
		return false
	if is_casting:
		if ability.castable_while_casting and ability_controller.charges_left > 0:
			cast_while_casting_ability = ability_controller.ability
			return true
		else:
			spell_queue.add_to_queue(ability_number)
			if CombatEvents.print_combat_events: print("already casting")
			return false
	if ability.charges > 1 and ability_controller.charges_left > 0:
#		print("%d charges left" % (ability_controller.charges_left -1))
		return true
	if ability_controller.ability_cooldown_timer.time_left > 0.0:
		if CombatEvents.print_combat_events: print("ability on cooldown")
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
		mouse_position_at_cast_time = Utils.get_mouse_world_coords()
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
			var _target = Utils.get_mouse_world_coords()
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
				cast.crit_damage_stat = stats.crit_damage
				cast.crit_multiplier = casting_ability.crit_damage_multiplier
			if casting_ability.splash:
				cast.splash_damage_multiplier = casting_ability.splash_damage_multiplier
			cast.target = _target
			get_parent().add_child(cast)
			cast.global_position = ability_spawn_position.global_position 
			is_casting = false
			CombatEvents.emit_cast_finished(casting_ability)
	else:
		if cast_while_casting_ability.ability_scene != null:
			var cast = cast_while_casting_ability.ability_scene.instantiate()
			@warning_ignore("narrowing_conversion")
			cast.damage = randi_range(cast_while_casting_ability.damage*0.95, cast_while_casting_ability.damage*1.05)
			if randf() < stats.get_crit_percent() + cast_while_casting_ability.additional_crit_chance:
				cast.is_crit = true
				cast.crit_damage_stat = stats.crit_damage
				cast.crit_multiplier = cast_while_casting_ability.crit_damage_multiplier
			if casting_ability.splash:
				cast.splash_damage_multiplier = cast_while_casting_ability.splash_damage_multiplier
			cast.target = _target
			get_parent().add_child(cast)
			cast.global_position = ability_spawn_position.global_position
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
		if (buff.has("modifies_ability") and buff.modifies_ability.id == ability.id) or shared_element:
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

func on_hover_timer_timeout() -> void:
	if Input.is_action_pressed("ui_left_click"): 
		if not mouse_pressed:
			mouse_release_action = "ui_left_click"
			mouse_pressed = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func on_target_timer_timeout() -> void:
	if not Input.is_action_pressed("ui_left_click"):
		var enemies = get_tree().get_nodes_in_group("enemy")
		target = null
		for enemy in enemies:
			if enemy.hovering:
				target = enemy
			else:
				enemy.body.material_overlay.set("shader_parameter/enabled", false)
