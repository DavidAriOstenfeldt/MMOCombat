extends VBoxContainer

var buff_resource: BuffResource

@onready var icon: TextureRect = %Icon
@onready var sweep: TextureProgressBar = %Sweep
@onready var stack_label: Label = %StackLabel
@onready var timer_label: Label = %TimerLabel
@onready var duration_timer: Timer = $DurationTimer
@onready var panel_container: PanelContainer = $PanelContainer
var buff_tooltip: PanelContainer


func _ready() -> void:
	if buff_resource == null:
		queue_free()
		return
	if buff_resource.hidden:
		panel_container.visible = false
		timer_label.visible = false
	if buff_resource.duration != 0:
		duration_timer.wait_time = buff_resource.duration
		duration_timer.start()
	else:
		sweep.visible = false
		timer_label.text = ""
	icon.texture = buff_resource.icon
	if buff_resource.stacks:
		stack_label.visible = true
	else:
		stack_label.visible = false
		
	duration_timer.timeout.connect(on_duration_timeout)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	CombatEvents.buff_lost.connect(on_buff_lost)
	
	
func _process(delta: float) -> void:
	if !duration_timer.is_stopped():
		sweep.value = 1 -(duration_timer.time_left / duration_timer.wait_time)
		timer_label.text = "%.1f" % duration_timer.time_left
	
	if buff_resource.stacks:
		stack_label.text = "%d" % buff_resource.current_stacks


func on_duration_timeout() -> void:
	queue_free()
	if buff_tooltip.visible:
		buff_tooltip.reset_tooltip()
		buff_tooltip.hide()


func on_buff_lost(buff: BuffResource) -> void:
	if buff == buff_resource:
		queue_free()
		if buff_tooltip.visible:
			buff_tooltip.reset_tooltip()
			buff_tooltip.hide()

func on_mouse_entered() -> void:
	if buff_tooltip != null:
		buff_tooltip = buff_tooltip as BuffTooltip
		buff_tooltip.update_tooltip(buff_resource)
		buff_tooltip.position = get_screen_position() - Vector2(
			-(size.x/2),
			(size.y/4 + buff_tooltip.size.y)
		)
		buff_tooltip.visible = true

func on_mouse_exited() -> void:
	if buff_tooltip != null:
		buff_tooltip = buff_tooltip as BuffTooltip
		buff_tooltip.reset_tooltip()
		buff_tooltip.hide()

