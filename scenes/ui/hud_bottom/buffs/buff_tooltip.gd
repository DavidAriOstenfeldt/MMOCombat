extends PanelContainer
class_name BuffTooltip

@export var buff_resource: BuffResource

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel



func _ready() -> void:
	hide()
	reset_tooltip()



func update_tooltip(buff: BuffResource) -> void:
	name_label.text = buff.name
	
		
	# TODO: Make work with flat amounts as well
	var description = buff.description
	description = description.replace("{amount}", "%d" % (buff.perc_amount*100*buff.rank) + "%")
	description = description.replace("{stack*amount}", "%d" % (buff.perc_amount*100 * buff.current_stacks*buff.rank) + "%")
	
	description_label.text = description
	
	reset_size()


func reset_tooltip() -> void:
	name_label.text = ""
	description_label.text = ""
	reset_size()
