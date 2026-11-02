class_name FSMViewState
extends FSMState

@export var scene: PackedScene

func _init(state_id: StringName, scene_param: PackedScene) -> void:
	id = state_id
	scene = scene_param
