class_name MediaSortUI
extends PanelContainer

@onready var method_options: OptionGroup = %MethodOptions
@onready var direction_options: OptionGroup = %DirectionOptions

func _ready() -> void:
	if not Services.media_library_controller:
		return
		
	var methods: Array[StringName]
	var directions: Array[StringName]
	
	match(Services.media_library_controller.sort_mode):
		MediaLibrary.SortMode.TITLE:
			methods = ["Title"]
		MediaLibrary.SortMode.LAST_PLAYED:
			methods = ["LastPlayed"]
		MediaLibrary.SortMode.PLAY_COUNT:
			methods = ["PlayCount"]
		MediaLibrary.SortMode.DURATION:
			methods = ["Duration"]
			
	if Services.media_library_controller.sort_descending:
		directions = ["Descending"]
	else:
		directions = ["Ascending"]
		
	method_options.select_buttons(methods)
	direction_options.select_buttons(directions)

# this updates the settings on close button
# if needed as live preview need to implement the selection_changed signal
func _on_close_button_pressed() -> void:
	var methods := method_options.get_selected_option_ids()
	var directions := direction_options.get_selected_option_ids()
	
	if methods.size() == 1 and directions.size() == 1:
		var sort_mode: MediaLibrary.SortMode
		var soret_decending: bool = false
		
		match methods[0]:
			"Title":
				sort_mode = MediaLibrary.SortMode.TITLE
			"LastPlayed":
				sort_mode = MediaLibrary.SortMode.LAST_PLAYED
			"PlayCount":
				sort_mode = MediaLibrary.SortMode.PLAY_COUNT
			"Duration":
				sort_mode = MediaLibrary.SortMode.DURATION
				
		match directions[0]:
			"Descending":
				soret_decending = true
			"Ascending":
				soret_decending = false
		
		# TODO: direct access the controller - maybe Intent is needed later
		Services.media_library_controller.sort_mode = sort_mode
		Services.media_library_controller.sort_descending = soret_decending
	
	FSMEventGateway.push("travel_media_browser")
