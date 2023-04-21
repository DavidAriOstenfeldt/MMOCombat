extends Resource
class_name BuffResource


@export var id: String
@export var icon: Texture
@export var name: String = "Buff"
@export_multiline var description: String = "This is a buff."
@export var hidden: bool = false
@export var duration: float = 5
@export var tick_interval: float = 1
@export_group("Modifiers")
@export var modifies_ability: AbilityResource
@export var ability_stat_modifiers: AbilityStatModifierResource
@export var modifies_player: PlayerStats
@export var player_stat_modifiers: PlayerStatModifierResource
@export var flat_amount: float = 0.
@export_range(0., 1.) var perc_amount: float = 0.
@export var debuff: bool = false
@export var stacks: bool = false
@export var max_stacks: int = 0
@export var current_stacks: int = 0
var rank: int = 1
@export_group("Conditions")
@export var element_condition: ElementTypeResource
@export var unit_type_condition: UnitTypeResource
