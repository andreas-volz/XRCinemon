class_name HandMotionReaction
extends Node

@export var function_pointer_left: XRToolsFunctionPointer
@export var function_pointer_right: XRToolsFunctionPointer
@export var tool_hand_left: XRToolsHand
@export var tool_hand_right: XRToolsHand

@export var controller_tranparency := 0.0

#var pointing_hit_left := false
#var pointing_hit_right = false

func _ready() -> void:
	pass
	#function_pointer_left.pointing_event.connect(_on_left_pointing_event)
	#function_pointer_right.pointing_event.connect(_on_right_pointing_event)

func change_function_pointer_state(function_pointer: XRToolsFunctionPointer, is_transforming: bool) -> void:
		if is_transforming and function_pointer:
			function_pointer.show_laser = XRToolsFunctionPointer.LaserShow.SHOW
		else:
			function_pointer.show_laser = XRToolsFunctionPointer.LaserShow.COLLIDE

func set_controller_transparency(node: Node, transparency: float) -> void:
	if node is GeometryInstance3D:
		node.transparency = transparency

	for child in node.get_children():
		set_controller_transparency(child, transparency)
		
#func _on_left_pointing_event(event: Variant):
	#pointing_hit_left = true
	#
#func _on_right_pointing_event(event: Variant):
	#pointing_hit_right = true

func _on_motion_detector_right_motion_changed(is_transforming: bool) -> void:
	change_function_pointer_state(function_pointer_right, is_transforming)
	var transparency: float
	if is_transforming:
		transparency = 0.0
	else: 
		transparency = controller_tranparency
	set_controller_transparency(tool_hand_right, transparency)

func _on_motion_detector_left_motion_changed(is_transforming: bool) -> void:
	change_function_pointer_state(function_pointer_left, is_transforming)
	var transparency: float
	if is_transforming:
		transparency = 0.0
	else: 
		transparency = controller_tranparency
	set_controller_transparency(tool_hand_left, transparency)
