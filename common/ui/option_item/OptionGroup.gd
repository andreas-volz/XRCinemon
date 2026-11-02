@tool
@icon("OptionGroup.svg")
class_name OptionGroup
extends Node

## link to the top level container which contains all OptionItemButtons which should be colelcted for this OptionGroup
@export var option_items_link: Control

signal selection_changed(button: OptionItemButton)

## Defines the selection behavior of the option group.
enum SelectionMode {
	SINGLE,          ## Allows at most one selection; none is also valid.
	SINGLE_REQUIRED, ## Requires exactly one selection.
	MULTIPLE         ## Allows any number of selections.
}

var buttons: Array[OptionItemButton] = []
var button_group := ButtonGroup.new()

@export var selection_mode: SelectionMode = SelectionMode.SINGLE : set=set_selection_mode

func _ready() -> void:
	_collect_buttons(option_items_link)
	set_selection_mode(selection_mode)
	
	var option_id_index : Dictionary
	for button in buttons:
		if option_id_index.has(button.option_id):
			push_warning("Each OptionItemButton in the same OptionGroup needed an exclusive option_id: %s:%s " % [button, button.option_id])
		option_id_index[button.option_id] = button

func set_selection_mode(selection_mode_param: SelectionMode):
	selection_mode = selection_mode_param
	
	var pressed_count := 0
	for button in buttons:
		if selection_mode == SelectionMode.SINGLE:
			button_group.allow_unpress = true
			button.button_group = button_group
		elif selection_mode == SelectionMode.SINGLE_REQUIRED:
			button_group.allow_unpress = false
			button.button_group = button_group
		elif selection_mode == SelectionMode.MULTIPLE:
			button.button_group = null
			
		if button.button_pressed:
			pressed_count += 1
			
		button.pressed.connect(_on_button_pressed.bind(button))

	if selection_mode == SelectionMode.SINGLE_REQUIRED and pressed_count == 0:
		if not buttons.is_empty():
			var first_button: OptionItemButton = buttons.front()
			if first_button:
				first_button.button_pressed = true

func get_selected_buttons() -> Array[OptionItemButton]:
	var selected_buttons: Array[OptionItemButton] = []
	for button in buttons:
		if button.button_pressed:
			selected_buttons.append(button)
	return selected_buttons
	
func get_selected_option_ids() -> Array[StringName]:
	var option_ids: Array[StringName] = []
	for selected_button in get_selected_buttons():
		option_ids.append(selected_button.option_id)
	return option_ids
	
func get_button(option_id: StringName) -> OptionItemButton:
	for button in buttons:
		if button.option_id == option_id:
			return button
	return null
	
func select_buttons(button_ids: Array[StringName]):
	var single_select: StringName
	for button_id in button_ids:
		var button := get_button(button_id)
		if button:
			if selection_mode == SelectionMode.SINGLE or selection_mode == SelectionMode.SINGLE_REQUIRED:
				if single_select.is_empty():
					single_select = button.option_id
					button.button_pressed = true
				else:
					button.button_pressed = false
			elif selection_mode == SelectionMode.MULTIPLE:
				button.button_pressed = true
	
	if selection_mode == SelectionMode.SINGLE_REQUIRED and single_select.is_empty():
		if not buttons.is_empty():
			var first_button: OptionItemButton = buttons.front()
			if first_button:
				first_button.button_pressed = true

func _collect_buttons(node: Node) -> void:
	if option_items_link:
		for child in node.get_children():
			if child is OptionItemButton:
				buttons.append(child)
			_collect_buttons(child)

func _on_button_pressed(button: Button) -> void:
	selection_changed.emit(button)
