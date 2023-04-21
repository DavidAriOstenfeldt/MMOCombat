extends ProgressBar

@onready var cast_bar_timer: Timer = %CastBarTimer
@onready var cast_bar_label: Label = %CastBarLabel

var ability_name: String
var abilities: Array[AbilityController]


func _ready() -> void:
	CombatEvents.cast_started.connect(on_cast_started)
	CombatEvents.cast_cancelled.connect(on_cast_cancelled)
	GameEvents.abilities_updated.connect(on_abilities_updated)
	cast_bar_timer.timeout.connect(on_cast_bar_timer_timeout)
	set_process(false)
	visible = false


func _process(delta: float) -> void:
	value = 1 - (cast_bar_timer.time_left / cast_bar_timer.wait_time)
	cast_bar_label.text = "%s %.1f" % [ability_name, cast_bar_timer.time_left]


func update_abilities(_abilities: Array[AbilityController]) -> void:
	abilities = _abilities


func on_cast_started(cast_time: float, ability_number: int, _ability_cooldown: float, _ability: AbilityResource = null) -> void:
	if cast_time <= 0.0:
		return
	var ability = abilities[ability_number].ability
	ability_name = ability.name
	cast_bar_timer.wait_time = cast_time 
	cast_bar_timer.start()
	set_process(true)
	visible = true
	

func on_cast_cancelled() -> void:
	ability_name = ""
	visible = false
	set_process(false)
	cast_bar_timer.stop()


func on_cast_bar_timer_timeout() -> void:
	ability_name = ""
	visible = false
	set_process(false)
	

func on_abilities_updated(_abilities: Array[AbilityController]) -> void:
	update_abilities(_abilities)
