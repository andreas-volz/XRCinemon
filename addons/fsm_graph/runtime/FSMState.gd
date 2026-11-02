class_name FSMState
extends RefCounted

@warning_ignore("unused_signal")
signal entered
@warning_ignore("unused_signal")
signal exited

var id: StringName

## key=in_event, type=StringName
## value=out_event, type=StringName
var event_mapping: Dictionary = {}

## key=in_event, type=StringName
## value=out_event, type=FSMEvent
var fsm_event_index: Dictionary = {}

func _init(state_id: StringName) -> void:
	id = state_id

func add_event_mapping(in_event_id: StringName, out_event_id: StringName):
	event_mapping[in_event_id] = out_event_id
	
func get_event_mapping(in_event_id: StringName, default: StringName = "") -> StringName:
	return event_mapping.get(in_event_id, default)

func add_event(event_id: StringName):
	fsm_event_index[event_id] = FSMEvent.new(event_id)

func get_event(event_id: StringName) -> FSMEvent:
	# use the out_event if available otherwise in_event
	var mapped_event: StringName = event_mapping.get(event_id, event_id)
	
	var fsm_event: FSMEvent = fsm_event_index.get(mapped_event, FSMEvent.null_event)
	
	return fsm_event

#@export var enter_actions: Array[Intent]
#@export var exit_actions: Array[Intent]
