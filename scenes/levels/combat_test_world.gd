extends Node3D

@onready var path_follow_3d: PathFollow3D = $Entities/Path3D/PathFollow3D

var path_follow_speed = .005

func _physics_process(delta: float) -> void:
	path_follow_3d.progress_ratio += path_follow_speed
