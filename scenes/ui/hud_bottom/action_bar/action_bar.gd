extends HBoxContainer
class_name ActionBar

var abilities: Array[AbilityController]
var ability_buttons: Array[AbilityButton]
@export var ability_button_scene: PackedScene
@export var number_of_ability_buttons: int = 10
@onready var global_cooldown_timer: Timer = $GlobalCooldownTimer
@onready var ability_tooltip: PanelContainer = %AbilityTooltip


func _ready():
	GameEvents.abilities_updated.connect(on_abilities_updated)
	CombatEvents.cast_started.connect(on_cast_started)
	CombatEvents.global_cooldown_started.connect(on_global_cooldown_started)
	
	for i in range(number_of_ability_buttons):
		var button_instance = ability_button_scene.instantiate()
		button_instance = button_instance as AbilityButton
		add_child(button_instance)
		button_instance.global_cooldown_timer = global_cooldown_timer
		button_instance.sweep.visible = false
		button_instance.text = ""
		
		var shortcut = Shortcut.new()
		var action = InputEventAction.new()
		if i == 9:
			button_instance.hotkey_label.text = str(0)
			action.action = "ability_%d" % (0)
		else:
			action.action = "ability_%d" % (i+1)
			button_instance.hotkey_label.text = str(i+1)
			
		shortcut.events = [action]
		button_instance.shortcut = shortcut
		
		button_instance.mouse_entered.connect(on_ability_button_mouse_entered.bind(button_instance))
		button_instance.mouse_exited.connect(on_ability_button_mouse_exited.bind(button_instance))
		ability_buttons.append(button_instance)


func update_ability_buttons(_abilities: Array[AbilityController]) -> void:
	abilities = _abilities
	var _count: int = 0
	for ability_controller in abilities:
		var _ability = ability_controller.ability
		ability_buttons[_count].icon = _ability.icon
		ability_buttons[_count].charges_label.text = str(_ability.charges)
		ability_buttons[_count].ability_slot = _count
		ability_buttons[_count].pressed.connect(on_ability_button_pressed.bind(ability_buttons[_count].ability_slot))
		if _ability.charges > 1:
			ability_buttons[_count].show_charges = true
			ability_buttons[_count].charges_label.visible = true
			ability_buttons[_count].max_charges = _ability.charges
			ability_buttons[_count].charges_left = _ability.charges
		_count += 1


func on_cast_started(cast_time: float, ability_number: int, ability_cooldown: float = 0.0, ability: AbilityResource = null) -> void:
	var ability_button = ability_buttons[ability_number]
	ability_button.charges_left = abilities[ability_number].charges_left
	if ability_cooldown > 0.0:
#		print(self, " started sweep with %.2f" % ability_cooldown)
		ability_button.start_sweep(ability_cooldown)
		


func on_global_cooldown_started(gcd_time: float) -> void:
	global_cooldown_timer.wait_time = gcd_time
	global_cooldown_timer.start()
	for ability_button in ability_buttons:
		if ability_button.icon == null:
			continue
#		print(self, " started gcd with %.2f" % gcd_time)
		ability_button.start_sweep(global_cooldown_timer.wait_time)


func on_abilities_updated(_abilities: Array[AbilityController]) -> void:
	update_ability_buttons(_abilities)
	
	
func on_ability_button_mouse_entered(ability_button: AbilityButton) -> void:
	if ability_button.icon == null:
		return
	ability_tooltip.update_tooltip(abilities[ability_button.position.x/68].ability)
	if ability_tooltip != null:
		ability_tooltip.position = ability_button.get_screen_position() - \
									Vector2(-(ability_button.size.x/2),\
											(ability_button.size.y/4 + ability_tooltip.size.y))
		ability_tooltip.visible = true
	
	
func on_ability_button_mouse_exited(ability_button: AbilityButton) -> void:
	if ability_tooltip != null:
		ability_tooltip.reset_tooltip()
		ability_tooltip.hide()


func on_ability_button_pressed(ability_slot: int) -> void:
	GameEvents.emit_ability_button_pressd(ability_slot)

