@tool
class_name FSMStateResource
extends Resource

@export_storage var uid: int

@export var title: String

@export var scene: PackedScene

@export var inital: bool = false

@export var event_slots: Array[FSMEventSlotResource] = []
@export var event_mappings: Array[FSMEventMappingResource] = []

@export_storage var next_event_slot_uid: int = 0

@export_storage var editor_data := FSMStateEditorResource.new()

func get_runtime_id() -> StringName:
	var runtime_id: String = ""
	var last_was_separator := false
	
	for character in title:
		if (character >= "A" and character <= "Z"):
			runtime_id += character.to_lower()
		elif ((character >= "a" and character <= "z") or
			(character >= "0" and character <= "9")
		):
			runtime_id += character
		elif not last_was_separator:
			runtime_id += "_"
			last_was_separator = true
			
	runtime_id = runtime_id.trim_prefix("_")
	runtime_id = runtime_id.trim_suffix("_")
	
	runtime_id += "_" + str(uid)
	
	return runtime_id
