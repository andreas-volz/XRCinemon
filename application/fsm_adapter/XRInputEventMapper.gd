class_name XRInputEventMapper
extends Node

var _controller: XRController3D
@export var event_bindings: Array[EventBinding]

# Called when our node is added to our scene tree
func _enter_tree():
	_controller = XRHelpers.get_xr_controller(self)


# Called when our node is removed from our scene tree
func _exit_tree():
	_controller = null

func _ready() -> void:
	_controller.button_pressed.connect(_on_button_pressed)
	_controller.button_released.connect(_on_button_released)
	_controller.input_vector2_changed.connect(_on_input_vector2_changed)
	_controller.input_float_changed.connect(_on_input_float_changed)

func _on_button_pressed(signal_name: String):
	#print("_on_button_pressed: ", signal_name)
	for event_binding: EventBinding in event_bindings:
		if event_binding is ButtonEventBinding:
			if event_binding.input_event_type == ButtonEventBinding.InputEventType.PRESSED:
				if signal_name == event_binding.input_event:
					FSMEventGateway.push(event_binding.output_event)

func _on_button_released(signal_name: String):
	#print("_on_button_released: ", signal_name)
	for event_binding: EventBinding in event_bindings:
		if event_binding is ButtonEventBinding:
			if event_binding.input_event_type == ButtonEventBinding.InputEventType.RELEASED:
				if signal_name == event_binding.input_event:
					FSMEventGateway.push(event_binding.output_event)

func _on_input_vector2_changed(signal_name: String, value: Vector2):
	#print("_on_input_vector2_changed: ", signal_name, " : ", value)
	for event_binding: EventBinding in event_bindings:
		if event_binding is VariableEventBinding and event_binding.data_type == VariableEventBinding.DataType.VECTOR2:
			if signal_name == event_binding.input_event:
				FSMEventGateway.set_vector2_variable(event_binding.output_event, value)
				
func _on_input_float_changed(signal_name: String, value: float):
	for event_binding: EventBinding in event_bindings:
		if event_binding is VariableEventBinding and event_binding.data_type == VariableEventBinding.DataType.FLOAT:
			if signal_name == event_binding.input_event:
				FSMEventGateway.set_float_variable(event_binding.output_event, value)
