extends Node
class_name AbilityController

@export var ability: AbilityResource

var charges_left: int = 1
@onready var ability_cooldown_timer = $AbilityCooldownTimer
@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	ability_cooldown_timer.timeout.connect(on_ability_cooldown_timer_timeout)
	await get_tree().process_frame
	charges_left = ability.charges


func on_ability_cooldown_timer_timeout() -> void:
	charges_left += 1
#	print("added 1 charge, total %d" % charges_left)
	if charges_left < ability.charges:
		ability_cooldown_timer.start()
		
	
