@tool
@icon("OptionItemButton.svg")
class_name OptionItemButton
extends Button

@export var option_id: StringName

func _init() -> void:
	theme_type_variation = &"OptionItemButton"

func _ready() -> void:
	toggle_mode = true
