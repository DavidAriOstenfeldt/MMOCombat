extends Control

@onready var health_bar = $HealthBar
@onready var health_change_bar = $HealthChanged

@export var tint: Color

func _ready():
	health_bar.tint_progress = tint
	var par = get_parent()
	par.health_updated.connect(_on_health_updated)
	par.max_health_updated.connect(_on_max_health_updated)
	health_change_bar.value = health_bar.value
	health_change_bar.max_value = health_bar.max_value
	health_change_bar.size = health_bar.size


func _on_health_updated(new_health: int):
	health_bar.value = new_health
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(health_change_bar, "value", new_health, 0.5)
	
func _on_max_health_updated(new_health: int):
	health_bar.max_value = new_health
	health_change_bar.max_value = new_health
	
