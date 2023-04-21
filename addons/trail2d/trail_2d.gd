extends Line2D


@export var emit := true
@export var lifetime := 0.5
@export var distance := 20.0
@export var segments := 20
var target

var trail_points := []
var offset := Vector2()

class Point:
	var position := Vector2()
	var age       := 0.0

	func _init(position :Vector2, age :float) -> void:
		self.position = position
		self.age = age
	
	func update(delta :float, points :Array) -> void:
		self.age -= delta
		if self.age <= 0:
			points.erase(self)


func _ready():
	offset = position
	show_behind_parent = true
	target = get_parent()
	clear_points()
	set_as_top_level(true)
	position = Vector2()

func _emit():
	var _rotated_offset :Vector2 = offset.rotated(target.rotation)
	var _position :Vector2 = target.global_transform.origin + _rotated_offset
	var point = Point.new(_position, lifetime)
	
	if trail_points.size() < 1:
		trail_points.push_back(point)
		return
	
	if trail_points[-1].position.distance_squared_to(_position) > distance*distance:
		trail_points.push_back(point)
	
	update_points()
	
func update_points() -> void:
	var delta = get_process_delta_time()
		
	if trail_points.size() > segments:
		trail_points.reverse()
		trail_points.resize(segments)
		trail_points.reverse()
	
	clear_points()
	for point in trail_points:
		point.update(delta, trail_points)
		
#		if point:
		add_point(point.position)
	

func _process(delta):
	if emit:
		_emit()
		
