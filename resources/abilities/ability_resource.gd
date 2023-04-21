extends Resource
class_name AbilityResource

@export var id: String
@export var ability_scene: PackedScene
@export var icon: Texture
@export var name: String
@export_multiline var description: String
@export_enum("Instant", "Cast") var cast_type: String = "Cast"
@export var cast_time: float = 1.5
@export var elements: ElementTypeResource
@export var damage: float = 5
@export var splash: bool = false
@export var splash_damage_multiplier: float = 1
@export var aoe: bool = false
@export var additional_crit_chance: float = 0.0
@export var crit_damage_multiplier: float = 1.0
@export var cooldown: float = 0.0
@export var charges: int = 1
@export var castable_while_casting: bool = false
@export var cast_on_mouse: bool = false
@export var cast_while_moving: bool = false

