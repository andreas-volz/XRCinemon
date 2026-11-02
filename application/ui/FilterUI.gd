class_name FilterUI
extends PanelContainer

signal tags_changed

const FILTER_TAG_BUTTON = preload("uid://bd75jr6fwtwok")

@onready var tags_container: HFlowContainer = %TagsContainer

func _ready() -> void:
	rebuild_tags()
	
func rebuild_tags():
	for child in tags_container.get_children():
		child.queue_free()
	
	var available_tags: Array[String]
	if Services.media_library_controller:
		available_tags = Services.media_library_controller.media_library.get_available_tags()

	for tag: String in available_tags:
		var filter_tag_button: FilterTagButton = FILTER_TAG_BUTTON.instantiate()
		tags_container.add_child(filter_tag_button)
		
		filter_tag_button.changed_tag.connect(_on_changed_tag)
		
		filter_tag_button.text = tag
		
		if Services.media_library_controller.selected_media_descriptor:
			if Services.media_library_controller.selected_media_descriptor.tags.has(tag):
				filter_tag_button.button_pressed = true

func get_selected_tags() -> Array[String]:
	var tags_arrays: Array[String] = []
	for child in tags_container.get_children():
		if child.button_pressed:
			tags_arrays.append(child.text)
	return tags_arrays

func set_disabled(value: bool):
	for child in tags_container.get_children():
		child.disabled = value

func _on_changed_tag(tag: String, enabled: bool):
	print("tag: ", tag, " -> ", enabled)
	if Services.media_library_controller.selected_media_descriptor:
		if enabled:
			Services.media_library_controller.selected_media_descriptor.add_tag(tag)
		else:
			Services.media_library_controller.selected_media_descriptor.remove_tag(tag)
	tags_changed.emit()
