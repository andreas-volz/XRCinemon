class_name FSMEvent
extends RefCounted

@warning_ignore("unused_signal")
signal matched

static var null_event := FSMEvent.new("__null__")

var id: StringName

func _init(id_param: StringName = &"") -> void:
	id = id_param
