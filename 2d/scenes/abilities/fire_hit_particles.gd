extends Node2D
@onready var timer: Timer = $Timer
@onready var ring: GPUParticles2D = $Ring
@onready var sparks: GPUParticles2D = $Sparks


func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)
	timer.wait_time = ring.lifetime
	timer.start()
	sparks.emitting = true
	ring.emitting = true
	

func on_timer_timeout() -> void:
	queue_free()
