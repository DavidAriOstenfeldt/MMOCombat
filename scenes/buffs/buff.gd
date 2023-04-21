extends Node
class_name Buff

@export var buff_resource: BuffResource

@onready var duration_timer: Timer = $DurationTimer
@onready var tick_timer: Timer = $TickTimer


func _ready():
	tick_timer.timeout.connect(on_tick)
	duration_timer.timeout.connect(on_duration_end)
	await get_tree().process_frame
	on_apply()


func on_apply():
	CombatEvents.emit_buff_applied(buff_resource)
	
	if buff_resource.duration != 0:
		duration_timer.wait_time = buff_resource.duration
		duration_timer.start()
	if buff_resource.tick_interval != 0:
		tick_timer.wait_time = buff_resource.tick_interval
		tick_timer.start()


func on_tick():
	pass
	

func on_duration_end():
	CombatEvents.emit_buff_lost(buff_resource)
	if buff_resource.stacks:
		buff_resource.current_stacks = 1
	queue_free()


func on_remove():
	CombatEvents.emit_buff_lost(buff_resource)
	if buff_resource.stacks:
		buff_resource.current_stacks = 1
	queue_free()
