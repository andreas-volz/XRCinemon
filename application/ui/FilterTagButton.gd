class_name FilterTagButton
extends Button

signal changed_tag(tag: String, enabled: bool)


func _on_toggled(toggled_on: bool) -> void:
	changed_tag.emit(text, toggled_on)
