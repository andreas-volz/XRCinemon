# class FSMEventGateway
extends Node

var _state_machine := ApplicationStateMachine.new()

var _event_variables_float: Dictionary = {}
var _event_variables_vector2: Dictionary = {}

func push(event_id: StringName):
	_state_machine.push(event_id)
	
func get_state(id: String) -> FSMState:
	return _state_machine.get_state(id)

func set_float_variable(id: StringName, value: float) -> void:
	_event_variables_float[id] = value

func get_float_variable(id: StringName, default: float = 0.0) -> float:
	if _event_variables_float.has(id):
		return _event_variables_float[id]
	return default

func set_vector2_variable(id: StringName, value: Vector2) -> void:
	_event_variables_vector2[id] = value

func get_vector2_variable(id: StringName, default: Vector2 = Vector2.ZERO) -> Vector2:
	if _event_variables_vector2.has(id):
		return _event_variables_vector2[id]
	return default

# TODO: this is a problem as I don't like to use XRToolsViewport2DIn3D in the FSMGraph addon.
# TODO: define a facade layer!
func set_xr_viewport(xr_viewport_param: XRToolsViewport2DIn3D):
	_state_machine.set_xr_viewport(xr_viewport_param)
