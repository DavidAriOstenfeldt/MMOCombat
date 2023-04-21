extends Resource
class_name TalentResource

@export var id: String
@export var icon: Texture
@export var name: String = "Talent Name"
@export_multiline var description: String = "This is a talent."
var current_rank: int = 0
@export var max_rank: int = 1
@export var resource: Resource
@export var passive: bool = false
@export var ability: bool = false
@export var use_resource_description: bool = false




