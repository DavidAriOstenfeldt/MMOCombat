extends Resource
class_name PlayerStats

@export var crit_rating := 5.
@export var haste_rating := 5.
@export var versatility_rating := 5.
@export var mastery_rating := 5.
@export var current_level := 1
@export var talent_points_available: int =  1
@export var global_cooldown: float = 1.5
@export var minimum_gcd: float = .75
@export var crit_damage: float = 2.


func get_haste_percent() -> float:
	return 1. + ((haste_rating / 100.) / current_level)
	
func get_crit_percent() -> float:
	return 0. + ((crit_rating / 100.) / current_level)
	
func get_versatility_percent() -> float:
	return 0. + ((versatility_rating / 100.) / current_level)

func get_mastery_percent() -> float:
	return 0. + ((mastery_rating / 100.) / current_level)

func get_global_cooldown() -> float:
	return max(global_cooldown / get_haste_percent(), minimum_gcd)
