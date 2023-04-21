extends Label3D
class_name FloatingCombatText

var grav = Vector3.DOWN
var mass = 50
var velocity = Vector3.ZERO
var acceleration = .025

var to_scale: Vector3 = Vector3.ONE * .5
var finish_scale: Vector3 = Vector3.ONE *.25


var direction_to_player: Vector3 = Vector3.ZERO
var is_crit: bool = false

func _ready():
	if is_crit:
		to_scale *= 2
		text += "!"
		#modulate = Color("ff0044")
	
	var tween = create_tween()
	tween.chain()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "scale", to_scale, .25).from(Vector3.ZERO)
	tween.set_trans(Tween.TRANS_CUBIC)
	var max_scale_time = .25
	if is_crit: max_scale_time = .5
	tween.tween_property(self, "scale", finish_scale, max_scale_time)
	tween.tween_property(self, "transparency", 1., .25).set_delay(.1)
	
	
	await tween.finished
	queue_free()


func _process(delta):
	if not is_crit:
		velocity += (Vector3.UP * acceleration) * delta
		position += velocity

