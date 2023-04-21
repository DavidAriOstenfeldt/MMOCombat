extends Button
class_name AbilityButton

@onready var sweep = $Sweep
@onready var sweep_timer = $SweepTimer
@onready var hotkey_label: Label = $HotkeyLabel
@onready var charges_label: Label = $ChargesLabel
@onready var charge_timer: Timer = $ChargeTimer

var charges_left: int
var max_charges: int
var show_charges: bool = false
var global_cooldown_timer: Timer
var ability_slot: int


func _ready() -> void:
	if not show_charges:
		charges_label.visible = false
	sweep_timer.timeout.connect(on_sweep_timer_timeout)
	charge_timer.timeout.connect(on_charge_timer_timeout)
	sweep.visible = false
	text = ""
	set_process(false)
	

func _process(delta: float) -> void:
	if charge_timer.time_left > sweep_timer.time_left:
		sweep.value = charge_timer.time_left / charge_timer.wait_time
		text = "%.1f" % charge_timer.time_left
	else:
		sweep.value = sweep_timer.time_left / sweep_timer.wait_time
		text = "%.1f" % sweep_timer.time_left


func start_sweep(sweep_time: float) -> void:
	charges_label.text = str(charges_left)
	
	# if new sweep time is less than time left
	# prevents overwriting lower cd
	if sweep_time <= sweep_timer.time_left:
#		print(self, " sweep time less than time left")
		return
	
	# if sweep_time is not a gcd
	if sweep_time != global_cooldown_timer.wait_time:
#		print(self, " sweep time not gcd")
		# if charge_timer is not already active
		# we active it
		if charge_timer.time_left == 0.:
#			print(self, " charge_timer not active")
			charge_timer.wait_time = sweep_time
			charge_timer.start()
			sweep.visible = true
			set_process(true)
			return
	else:
		sweep.visible = true
		sweep_timer.wait_time = sweep_time
		sweep_timer.start()
		set_process(true)
	


func on_sweep_timer_timeout() ->void:
	if charge_timer.time_left == 0.:
		sweep.visible = false
		text = ""
		set_process(false)

	if global_cooldown_timer.time_left > 0.0:
		start_sweep(global_cooldown_timer.time_left)
		
#	if show_charges and sweep_timer.wait_time != global_cooldown_timer.wait_time and charges_left < max_charges:
#		start_sweep(sweep_timer.wait_time)


func on_charge_timer_timeout() -> void:
	if sweep_timer.time_left == 0.:
		sweep.visible = false
		text = ""
		set_process(false)
	charges_left += 1
	charges_left = clampi(charges_left, 0, max_charges)
	charges_label.text = str(charges_left)
	if charges_left < max_charges:
		start_sweep(charge_timer.wait_time)

