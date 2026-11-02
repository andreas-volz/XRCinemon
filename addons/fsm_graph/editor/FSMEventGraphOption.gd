@tool
class_name FSMEventGraphOption
extends HBoxContainer

signal remove_request
signal event_changed(value: String)

var event: String : set=set_event
var changeable: bool : set=set_changeable

@onready var remove_button: Button = $RemoveButton
@onready var event_text: LineEdit = $EventText
@onready var default_label: Label = $DefaultLabel

func set_event(value: String):
	event = value
	var caret_column := event_text.caret_column
	event_text.text = value
	event_text.caret_column = caret_column

func set_changeable(value: bool):
	changeable = value
	remove_button.visible = changeable
	default_label.visible = !changeable
	event_text.visible = changeable
	event_text.editable = changeable

func _on_remove_button_pressed() -> void:
	remove_request.emit()

func _on_event_text_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		$EventText.text = event
	else:
		event = new_text
	event_changed.emit(event)
