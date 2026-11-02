@tool
class_name FSMStateGraphNode
extends GraphNode

const CLOSE = preload("uid://csqnlx44el1ic")
const EDIT = preload("uid://dbfg77h7ngreq")
const FSM_STATE_NODE_PANEL_STYLEBOX = preload("uid://bbotml7sxsm1d")

signal close_request
signal rebuild_request

# calling this disconnects all incoming transitions to this state and make this state an "Initial State"
# at the same time the Graph makes this one the only "Initial State" (on this hierarchie level - if hierarchie is later impelmented TODO)
signal make_inital_request

const FSM_EVENT_GRAPH_OPTION = preload("uid://vnt2l7il1q4l")
const FSM_EVENT_GRAPH_MAPPING = preload("uid://mmfh2mja5771")

const INPUT_EVENT_POSITION := 1
const OUTPUT_EVENT_START_POSITION := 2

var event_control_array: Array[Control]
var fsm_state_resource: FSMStateResource

var title_edit: LineEdit
var editable_title: String : set=set_editable_title



@onready var mapping_events_container: VBoxContainer = %MappingEventsContainer
@onready var input_initial_button: CheckButton = %InputInitialButton
@onready var runtime_id_label: Label = %RuntimeIDLabel
@onready var preview_sub_viewport: SubViewport = %PreviewSubViewport

func _ready() -> void:
	rebuild_slots()
	configure_title_bar()
		
	position_offset_changed.connect(_on_position_offset_changed)
	resized.connect(_on_resized)
	
func configure_title_bar():
	# configure the title bar
	var titlebar_hbox: HBoxContainer = get_titlebar_hbox()
	
	var title_label: Label = titlebar_hbox.get_child(0) # the label is always the first at default
	#title_label.visible = false

	var edit_button := Button.new()
	edit_button.icon = EDIT
	edit_button.toggle_mode = true
	edit_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	edit_button.toggled.connect(
		func(toggled_on): 
		title_edit.visible = toggled_on
		title_label.visible = !toggled_on
		if toggled_on:
			title_edit.grab_focus()
			title_edit.caret_column = title_edit.text.length()
		else:
			rebuild_request.emit()
		)
	titlebar_hbox.add_child(edit_button)
	titlebar_hbox.move_child(edit_button, 0)

	title_edit = LineEdit.new()
	title_edit.visible = false
	title_edit.text_changed.connect(_on_title_edit_text_changed)
	#title_edit.focus_exited.connect(func(): title_label.visible = true) # TODO: maybe a future UX improvement to close the edit line
	title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titlebar_hbox.add_child(title_edit)
	titlebar_hbox.move_child(title_edit, 1)
	
	var close_button := Button.new()
	close_button.icon = CLOSE
	close_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	close_button.pressed.connect(_on_close_button_pressed)
	titlebar_hbox.add_child(close_button)
	
func set_editable_title(value: String):
	editable_title = value
	var caret_column := title_edit.caret_column
	title_edit.text = editable_title
	title_edit.caret_column = caret_column
	title = editable_title
	fsm_state_resource.title = editable_title
		
func _on_close_button_pressed():
	close_request.emit()
	
func _on_add_event_button_pressed() -> void:
	var fsm_event_slot_resource := FSMEventSlotResource.new()
	
	# assign the next uid to the event slot resource...
	fsm_event_slot_resource.uid = fsm_state_resource.next_event_slot_uid
	
	# set initial name as default from uid (could be changed later in UI)
	fsm_event_slot_resource.id = "event_" + str(fsm_state_resource.next_event_slot_uid)
	
	# ...and iterate it afterwards
	fsm_state_resource.next_event_slot_uid += 1
	
	fsm_state_resource.event_slots.append(fsm_event_slot_resource)
	
	rebuild_request.emit()

func _on_add_event_mapping_button_pressed() -> void:
	var fsm_event_mapping_resource := FSMEventMappingResource.new()
	fsm_state_resource.event_mappings.append(fsm_event_mapping_resource)
	rebuild_request.emit()

func rebuild_slots():
	#s clear before rebuild
	for node in event_control_array:
		node.queue_free()
	event_control_array.clear()
	
	for child:Node in preview_sub_viewport.get_children():
		child.queue_free()
	
	runtime_id_label.text = fsm_state_resource.get_runtime_id()
		
	for fsm_event_slot_resource: FSMEventSlotResource in fsm_state_resource.event_slots:
		var slot_index := event_control_array.size() + INPUT_EVENT_POSITION + 1
		var event_option: FSMEventGraphOption = FSM_EVENT_GRAPH_OPTION.instantiate()
		event_control_array.append(event_option)
		add_child(event_option)
		if fsm_event_slot_resource.default:
			event_option.changeable = false
		move_child(event_option, slot_index)
		event_option.set_event(fsm_event_slot_resource.id)
		event_option.remove_request.connect(_on_event_option_remove_request.bind(fsm_event_slot_resource))
		event_option.event_changed.connect(_on_event_option_event_changed.bind(fsm_event_slot_resource))
		
	for fsm_event_mapping_resource: FSMEventMappingResource in fsm_state_resource.event_mappings:
		var fsm_event_graph_mapping: FSMEventGraphMapping = FSM_EVENT_GRAPH_MAPPING.instantiate()
		mapping_events_container.add_child(fsm_event_graph_mapping)
		fsm_event_graph_mapping.from_event = fsm_event_mapping_resource.from_event
		fsm_event_graph_mapping.to_event = fsm_event_mapping_resource.to_event
		fsm_event_graph_mapping.remove_request.connect(_on_event_mapping_remove_request.bind(fsm_event_mapping_resource))
		fsm_event_graph_mapping.event_changed.connect(_on_event_mapping_changed.bind(fsm_event_mapping_resource))
		
	# input slot first position
	input_initial_button.button_pressed = fsm_state_resource.inital
	if !fsm_state_resource.inital:
		set_slot(INPUT_EVENT_POSITION, true, FSMGraphEditor.ConnectionType.STATE_TRANSITION, Color.RED, false, -1, Color.WHITE)
	else:
		set_slot(INPUT_EVENT_POSITION, false, FSMGraphEditor.ConnectionType.STATE_TRANSITION, Color.RED, false, -1, Color.WHITE)
	
	# all Events that could add a transition
	for si in range(OUTPUT_EVENT_START_POSITION, OUTPUT_EVENT_START_POSITION + event_control_array.size()):
		set_slot(si, false, -1, Color.WHITE, true, FSMGraphEditor.ConnectionType.STATE_TRANSITION, Color.GREEN)
		
	if fsm_state_resource.scene:
		print("preview: ", fsm_state_resource.get_runtime_id())
		preview_sub_viewport.add_child(fsm_state_resource.scene.instantiate())
	
		
func _on_event_option_remove_request(fsm_event_slot_resource: FSMEventSlotResource):
	fsm_state_resource.event_slots.erase(fsm_event_slot_resource)
	rebuild_request.emit()
	
func _on_event_mapping_remove_request(fsm_event_mapping_resource: FSMEventMappingResource):
	fsm_state_resource.event_mappings.erase(fsm_event_mapping_resource)
	rebuild_request.emit()

func _on_event_mapping_changed(from: String, to: String, fsm_event_mapping_resource: FSMEventMappingResource):
	fsm_event_mapping_resource.from_event = from
	fsm_event_mapping_resource.to_event = to

func _on_event_option_event_changed(event_id: String, fsm_event_slot_resource: FSMEventSlotResource):
	fsm_event_slot_resource.id = event_id

func _on_position_offset_changed():
	fsm_state_resource.editor_data.position_offset = position_offset

func _on_resized():
	fsm_state_resource.editor_data.size = size

func _on_title_edit_text_changed(new_text: String):
	set_editable_title(new_text)
	

func _on_input_initial_button_toggled(toggled_on: bool) -> void:
	fsm_state_resource.inital = toggled_on
	make_inital_request.emit()
	rebuild_request.emit()
