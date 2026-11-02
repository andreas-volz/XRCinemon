@tool
class_name FSMGraphEditor
extends GraphEdit

enum ConnectionType {
	STATE_TRANSITION
}

const FSM_STATE_GRAPH_NODE = preload("uid://dpafcxhw8vt07")

var node_array: Array[FSMStateGraphNode] = []

# TODO: hard coded only until the addon is developed
var fsm_graph_resource_path := "res://application/state_machine/fsm_graph.tres"

@export var fsm_graph_resource: FSMGraphResource

@onready var connection_popup_menu: PopupMenu = $ConnectionPopupMenu

func _ready() -> void:
	print("FSMGraphEditor ready()")
	# setup the menu bar
	var menu_hbox := get_menu_hbox()
	var add_state_button := Button.new()
	add_state_button.text = "Add State"
	menu_hbox.add_child(add_state_button)
	menu_hbox.move_child(add_state_button, 0)
	add_state_button.pressed.connect(_on_add_state_button_pressed)
	
	# connection handling
	connection_request.connect(_on_connection_request)
	#disconnection_request.connect(_on_disconnection_request)
	
	# popup
	popup_request.connect(_on_popup_request)
	
# return could be null -> better check it
func getGraphNodeFromName(node_name: StringName) -> FSMStateGraphNode:
	var node: FSMStateGraphNode = get_node(NodePath(node_name))
	return node
	
func _on_add_state_button_pressed():
	var fsm_state_resource := FSMStateResource.new()
	
	# TODO: better inital position concept needed
	var gap := Vector2(20, 20) 
	var initial_pos := Vector2(60, 60)
	
	var graph_node_count := node_array.size()
	fsm_state_resource.editor_data.position_offset = initial_pos + gap * graph_node_count
	
	# assign the next uid to the state resource...
	fsm_state_resource.uid = fsm_graph_resource.next_state_uid
	
	# set initial name as default from uid (could be changed later in UI)
	fsm_state_resource.title = "New State"
	
	# ...and iterate it afterwards
	fsm_graph_resource.next_state_uid += 1
	
	fsm_graph_resource.states.append(fsm_state_resource)
	
	# add default event slot resource
	var fsm_event_slot_resource := FSMEventSlotResource.new()
	
	# assign the next uid to the event slot resource...
	fsm_event_slot_resource.uid = fsm_state_resource.next_event_slot_uid
	fsm_event_slot_resource.default = true
	# ... and explicit don't change the id as empty id is the default event
	
	# ...and iterate it afterwards
	fsm_state_resource.next_event_slot_uid += 1
	
	fsm_state_resource.event_slots.append(fsm_event_slot_resource)
		
	rebuild_graph_deferred()

func rebuild_graph_deferred():
	call_deferred("rebuild_graph")
	
func rebuild_graph():
	# clear before rebuild
	for node in node_array:
		node.free()
	node_array.clear()
	clear_connections()
	
	# delete all now deprecated transistions from not longer existing states or events
	var valid_transitions: Array[FSMTransitionResource] = []
	for fsm_transition_resource: FSMTransitionResource in fsm_graph_resource.transitions:
		if (fsm_graph_resource.states.has(fsm_transition_resource.from_state) and
			fsm_graph_resource.states.has(fsm_transition_resource.to_state)):
				if fsm_transition_resource.from_state.event_slots.has(fsm_transition_resource.from_event_slot):
					valid_transitions.append(fsm_transition_resource)
	fsm_graph_resource.transitions = valid_transitions
	
	for fsm_state_res: FSMStateResource in fsm_graph_resource.states:
		add_state(fsm_state_res)
		
	for fsm_transition_res: FSMTransitionResource in fsm_graph_resource.transitions:
		add_transition(fsm_transition_res)

		
func add_state(fsm_state_res: FSMStateResource):
	var state_node: FSMStateGraphNode = FSM_STATE_GRAPH_NODE.instantiate()
	state_node.fsm_state_resource = fsm_state_res
	add_child(state_node)
	node_array.append(state_node)
	
	state_node.editable_title = fsm_state_res.title
	state_node.position_offset = fsm_state_res.editor_data.position_offset
	state_node.size = fsm_state_res.editor_data.size
	state_node.name = str(fsm_state_res.uid)
	
	if fsm_state_res.inital:
		state_node.add_theme_stylebox_override("panel", FSMStateGraphNode.FSM_STATE_NODE_PANEL_STYLEBOX)
		state_node.add_theme_stylebox_override("panel_selected", FSMStateGraphNode.FSM_STATE_NODE_PANEL_STYLEBOX)
	else:
		state_node.remove_theme_stylebox_override("panel")
		state_node.remove_theme_stylebox_override("panel_seelcted")
	
	state_node.close_request.connect(_on_state_node_close_request.bind(state_node.fsm_state_resource))
	state_node.make_inital_request.connect(_on_state_make_inital_request.bind(state_node.fsm_state_resource))
	state_node.rebuild_request.connect(_on_rebuild_request)
	

func add_transition(fsm_transition_resource: FSMTransitionResource):
	var from_node_name := str(fsm_transition_resource.from_state.uid)
	var to_node_name := str(fsm_transition_resource.to_state.uid)
	
	var from_port := find_port_from_transition(fsm_transition_resource)
	
	var to_port: int = 0 # always connect to port 0 in the current approach
	
	var from_node: FSMStateGraphNode = getGraphNodeFromName(from_node_name)
	var to_node: FSMStateGraphNode =  getGraphNodeFromName(to_node_name)
	
	print("connect nodes: %s:%d -> %s:%d" % [from_node_name, from_port, to_node_name, to_port])

	var error := connect_node(from_node_name, from_port, to_node_name, to_port)
	if error != Error.OK:
		pass
		# TODO: mark connected and unconneted slots in different color
		#from_node.set_slot_color_right(from_port, Color.GREEN)

# function to find the correct slot port that is used by a transition
# this works because the port index is the array position
# returns -1 if not found
func find_port_from_transition(fsm_transition_resource: FSMTransitionResource) -> int:
	# lambda function
	var from_port := fsm_transition_resource.from_state.event_slots.find_custom(
		func(value: FSMEventSlotResource): return value.uid == fsm_transition_resource.from_event_slot.uid)
	return from_port

func _on_connection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	var from_node: FSMStateGraphNode = getGraphNodeFromName(from_node_name)
	var to_node: FSMStateGraphNode =  getGraphNodeFromName(to_node_name)
	
	var fsm_transition_resource := FSMTransitionResource.new()
	fsm_transition_resource.from_state = from_node.fsm_state_resource
	fsm_transition_resource.to_state = to_node.fsm_state_resource
	fsm_transition_resource.from_event_slot = from_node.fsm_state_resource.event_slots[from_port]
	
	print("connect state resources: %s -> %s [port: %s]" %
		[fsm_transition_resource.from_state.title, fsm_transition_resource.to_state.title, fsm_transition_resource.from_event_slot.id])

	# search how many transitions are yet outgoing from this event to ensure each event has only *one* outgoing transition
	var event_connection_count := 0
	for fsm_transition_resource_search: FSMTransitionResource in fsm_graph_resource.transitions:
		if fsm_transition_resource_search.from_event_slot == fsm_transition_resource.from_event_slot:
			event_connection_count += 1
	
	# connect only if not yet connected
	if event_connection_count == 0:
		fsm_graph_resource.transitions.append(fsm_transition_resource)
	else:
		print("couldn't connect: %s:%d" % [from_node_name, from_port])
	
	rebuild_graph_deferred()
	
# I don't know if my graph edit could ever hit this
# TODO: let it some time around and remove the signal if never hit
#func _on_disconnection_request(from_node_name: StringName, from_port: int, to_node_name: StringName, to_port: int):
	#assert(false)
	#var from_node := getGraphNodeFromName(from_node_name)
	#var to_node := getGraphNodeFromName(to_node_name)
	#disconnect_node(from_node_name, from_port, to_node_name, to_port)
	#if get_connection_count(to_node_name, to_port) == 0:
		#to_node.set_slot_color_left(to_port, Color.RED)
	#rebuild_graph_deferred()
		
func _on_popup_request(at_position: Vector2):
	var connection: Dictionary = get_closest_connection_at_point(at_position)
	if not connection.is_empty():
		connection_popup_menu.position = at_position
		connection_popup_menu.visible = true
		connection_popup_menu.set_meta("connection", connection)
		
	
func _on_connection_popup_menu_id_pressed(id: int) -> void:
	if id == 0: # 0 is "Delete" as it has only one item
		var connection: Dictionary = connection_popup_menu.get_meta("connection")
		if connection != null:
			var from_node: FSMStateGraphNode = getGraphNodeFromName(connection.from_node)
			var to_node: FSMStateGraphNode =  getGraphNodeFromName(connection.to_node)
			
			# find all transitions that connect those specific states and ports
			# this should be only one in my model!
			# easiest is to put them into a temporary erase list - as it's not allowed to delete while in the Array
			var erease_list: Array[FSMTransitionResource] = []
			for fsm_transition_resource_search: FSMTransitionResource in fsm_graph_resource.transitions:
				if (fsm_transition_resource_search.from_state == from_node.fsm_state_resource and
					fsm_transition_resource_search.to_state == to_node.fsm_state_resource):
					var from_port := find_port_from_transition(fsm_transition_resource_search)
					if from_port == connection.from_port:
						erease_list.append(fsm_transition_resource_search)
						
			# ensure it has only one to find development errors
			assert(erease_list.size() == 1)
						
			# now really delete the found objects
			for fsm_transition_resource_erease: FSMTransitionResource in erease_list:
				fsm_graph_resource.transitions.erase(fsm_transition_resource_erease)
				
			rebuild_graph_deferred()

func disconnect_all_input_transitions(fsm_state_resource: FSMStateResource):
	# find all transitions that has the to target of the current state resource and mark it to delete
	var erease_list: Array[FSMTransitionResource] = []
	for fsm_transition_resource_search: FSMTransitionResource in fsm_graph_resource.transitions:
		if fsm_transition_resource_search.to_state == fsm_state_resource:
			erease_list.append(fsm_transition_resource_search)
			
	# now really delete the found objects
	for fsm_transition_resource_erease: FSMTransitionResource in erease_list:
		fsm_graph_resource.transitions.erase(fsm_transition_resource_erease)

func _on_state_make_inital_request(fsm_state_resource: FSMStateResource):
	disconnect_all_input_transitions(fsm_state_resource)
	for fsm_state_resource_search: FSMStateResource in fsm_graph_resource.states:
		if fsm_state_resource_search != fsm_state_resource:
			fsm_state_resource_search.inital = false
			
	rebuild_graph_deferred()

func _on_state_node_close_request(fsm_state_resource: FSMStateResource):
	fsm_graph_resource.states.erase(fsm_state_resource)
	rebuild_graph_deferred()
		
func _on_rebuild_request():
	rebuild_graph_deferred()

func load_resource(graph_resource: FSMGraphResource):
	fsm_graph_resource = graph_resource
	rebuild_graph_deferred()

func _on_load_button_pressed() -> void:
	fsm_graph_resource = ResourceLoader.load(ProjectSettings.globalize_path(fsm_graph_resource_path))
	
		# Test
	var application_state_machine := ApplicationStateMachine.new()
	application_state_machine.build_from_graph_resource(fsm_graph_resource)
	print("ApplicationStateMachine: ", application_state_machine)
	
	rebuild_graph_deferred()

func _on_save_button_pressed() -> void:
	var error := ResourceSaver.save(fsm_graph_resource, ProjectSettings.globalize_path(fsm_graph_resource_path))
	if error != Error.OK:
		print("ResourceSaver.save() Error: ", error)
	
