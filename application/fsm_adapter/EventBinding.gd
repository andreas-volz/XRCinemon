class_name EventBinding
extends Resource

@export var input_event: StringName
@export var output_event: StringName

func process_input(_event):
	push_error("Don't use - Must be overridden!")
