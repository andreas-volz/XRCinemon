@tool
class_name FSMEventGraphMapping
extends HBoxContainer

signal remove_request
signal event_changed(from: String, to: String)

@onready var from_edit: LineEdit = $FromEdit
@onready var to_edit: LineEdit = $ToEdit

var from_event: String : set=set_from_event
var to_event: String : set=set_to_event

func set_from_event(value: String):
	from_event = value
	var caret_column := from_edit.caret_column
	from_edit.text = value
	from_edit.caret_column = caret_column

func set_to_event(value: String):
	to_event = value
	var caret_column := to_edit.caret_column
	to_edit.text = value
	to_edit.caret_column = caret_column

func _on_remove_button_pressed() -> void:
	remove_request.emit()

func _on_from_edit_text_changed(_new_text: String) -> void:
	event_changed.emit(from_edit.text, to_edit.text)

func _on_to_edit_text_changed(_new_text: String) -> void:
	event_changed.emit(from_edit.text, to_edit.text)
