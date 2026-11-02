class_name GodotInputEventMapper
extends Node

@export var event_bindings: Array[EventBinding]

func _unhandled_input(event: InputEvent) -> void:
	
	for event_binding: EventBinding in event_bindings:
		if event_binding.input_event_type == ButtonEventBinding.InputEventType.PRESSED:
			if event.is_action_pressed(event_binding.input_event):
				FSMEventGateway.push(event_binding.output_event)
		if event_binding.input_event_type == ButtonEventBinding.InputEventType.RELEASED:
			if event.is_action_released(event_binding.input_event):
				FSMEventGateway.push(event_binding.output_event)
	
