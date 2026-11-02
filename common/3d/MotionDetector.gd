class_name MotionDetector
extends Node3D

signal motion_changed(is_transforming: bool)

@export var movement_threshold := 0.01
@export var rotation_threshold := 0.02
@export var still_time := 0.2

var _last_transform: Transform3D
var _is_transforming := false
var _still_timer := 0.0

func _ready() -> void:
	_last_transform = global_transform

func _process(delta: float) -> void:
	var moved := has_transformed()

	if moved:
		_still_timer = 0.0

		if not _is_transforming:
			_is_transforming = true
			motion_changed.emit(true)
	else:
		_still_timer += delta

		if _is_transforming and _still_timer >= still_time:
			_is_transforming = false
			motion_changed.emit(false)
		
func has_transformed() -> bool:
	var current := global_transform

	var moved := current.origin.distance_to(_last_transform.origin) > movement_threshold
	var rotated := current.basis.get_rotation_quaternion().angle_to(_last_transform.basis.get_rotation_quaternion()) > rotation_threshold
	_last_transform = current
	
	var transforming := moved or rotated
	
	return transforming
