extends Node

@export var passive_resource: PassiveResource

@export var spark_scene: PackedScene
@export var surge_scene: PackedScene
@export var surge_flamestrike_scene: PackedScene
@onready var buffer_timer: Timer = $BufferTimer


var spark: Buff = null
var surge: Buff = null
var surge_flamestrike: Buff = null

func _ready() -> void:
	CombatEvents.ability_hit.connect(on_ability_hit)
	CombatEvents.cast_started.connect(on_cast_started)
#	buffer_timer.timeout.connect(on_buffer_timer_timeout)


func on_ability_hit(ability: AbilityResource, damage: int, is_crit: bool) -> void:
	if ability.elements.type["Fire"] != true:
		return
	if ability.aoe == true:
		return
	
	if is_crit:
		var par_buffs = get_parent().get_parent().buffs
		if spark != null:
			surge = surge_scene.instantiate()
			surge_flamestrike = surge_flamestrike_scene.instantiate()
			par_buffs.add_child(surge)
			par_buffs.add_child(surge_flamestrike)
			spark.on_remove()
			spark = null
		elif surge == null:
			buffer_timer.start()
			spark = spark_scene.instantiate()
			par_buffs.add_child(spark)
	elif buffer_timer.time_left == 0.0:
		if spark != null:
			spark.on_remove()
			spark = null


func on_cast_started(_a, _b, _c, ability: AbilityResource = null) -> void:
	if surge == null and surge_flamestrike == null:
		return
	if ability.id != surge.buff_resource.modifies_ability.id \
		and ability.id != surge_flamestrike.buff_resource.modifies_ability.id:
		return
		
	surge.on_remove()
	surge = null
	surge_flamestrike.on_remove()
	surge_flamestrike = null
