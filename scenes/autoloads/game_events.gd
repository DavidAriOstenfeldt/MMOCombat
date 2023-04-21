extends Node

signal abilities_updated(abilities: Array[AbilityController])
signal ability_button_pressed(ability_slot: int)

func emit_abilities_updated(abilities: Array[AbilityController]) -> void:
	emit_signal("abilities_updated", abilities)

func emit_ability_button_pressd(ability_slot: int) -> void:
	emit_signal("ability_button_pressed", ability_slot+1)
