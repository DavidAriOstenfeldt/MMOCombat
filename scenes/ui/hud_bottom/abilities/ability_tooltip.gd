extends PanelContainer
class_name AbilityTooltip

@export var ability_resource: AbilityResource

@onready var name_label: Label = %NameLabel
@onready var icon: TextureRect = %Icon
@onready var cast_label: Label = %CastLabel
@onready var description_label: Label = %DescriptionLabel
@onready var type_label: Label = %TypeLabel
@onready var cooldown_label: Label = %CooldownLabel



func _ready() -> void:
	hide()
	await get_tree().process_frame
	reset_tooltip()



func update_tooltip(ability: AbilityResource) -> void:
	name_label.text = ability.name
	icon.texture = ability.icon
	
	if ability.cast_type == "Instant":
		cast_label.text = ability.cast_type
	else:
		if ability.cast_time == floor(ability.cast_time):
			cast_label.text = "%d seconds cast" % ability.cast_time
		else:
			cast_label.text = "%.1f seconds cast" % ability.cast_time
		
	var description = ability.description
	description = description.replace("{dam}", "%d-%d" % [ability.damage*0.95, ability.damage*1.05])
	
	# Get elements
	var element: String = Utils.get_elements_string(ability)
	description = description.replace("{type}", ("%s" % element.to_lower()))
	description = description.replace("{charges}", "%d" % ability.charges)
	description_label.text = description
	
	type_label.text = element
	if ability.cooldown > 0.0:
		if ability.cooldown == floor(ability.cooldown):
			cooldown_label.text = "%ds cooldown" % ability.cooldown
		else:
			cooldown_label.text = "%.1fs cooldown" % ability.cooldown
	else:
		cooldown_label.text = ""
	
	reset_size()

func reset_tooltip() -> void:
	name_label.text = ""
	description_label.text = ""
	type_label.text = ""
	icon.texture = null
	cast_label.text = ""
	cooldown_label.text = ""
	reset_size()
