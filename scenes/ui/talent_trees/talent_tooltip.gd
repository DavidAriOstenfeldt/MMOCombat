extends PanelContainer
class_name TalentTooltip

@export var talent_resource: TalentResource

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



func update_tooltip(resource: Resource) -> void:
	name_label.text = resource.name
	icon.texture = resource.icon
	
	if resource is AbilityResource:
		if resource.cast_type == "Instant":
			cast_label.text = resource.cast_type
		else:
			if resource.cast_time == floor(resource.cast_time):
				cast_label.text = "%d seconds cast" % resource.cast_time
			else:
				cast_label.text = "%.1f seconds cast" % resource.cast_time
			
		var description = resource.description
		description = description.replace("{dam}", "%d-%d" % [resource.damage*0.95, resource.damage*1.05])
		
		# Get elements
		var element: String = Utils.get_elements_string(resource)
		description = description.replace("{type}", ("%s" % element.to_lower()))
		description = description.replace("{charges}", "%d" % resource.charges)
		description_label.text = description
		
		type_label.text = element
		if resource.cooldown > 0.0:
			if resource.cooldown == floor(resource.cooldown):
				cooldown_label.text = "%ds cooldown" % resource.cooldown
			else:
				cooldown_label.text = "%.1fs cooldown" % resource.cooldown
		else:
			cooldown_label.text = ""
	elif resource is PassiveResource:
		var description = resource.description
		description = description.replace("{amount}", "%d" % (resource.amount*100*resource.rank) + "%")
		#description = description.replace("{stack*amount}", "%d" % (resource.perc_amount*100 * resource.current_stacks) + "%")
		description_label.text = description

	reset_size()
	
func update_tooltip_nyi(temp_resource: Resource = null) -> void:
	name_label.text = "NOT YET IMPLEMENTED"
	if temp_resource != null:
		icon.texture = temp_resource.icon
	cast_label.text = ""
	description_label.text = "Talent not yet implemented"
	type_label.text = ""
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
