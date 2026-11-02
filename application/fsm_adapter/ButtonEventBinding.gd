class_name ButtonEventBinding
extends EventBinding

enum InputEventType {
	PRESSED,
	RELEASED
}

@export var input_event_type: InputEventType = InputEventType.PRESSED
