class_name ApplicationStateMachine
extends RefCounted

const FSM_GRAPH = preload("res://application/state_machine/fsm_graph.tres")

const XR_CINEMON_THEME = preload("uid://dwr5xml22vbbm")

var _current_state: FSMState

var _state_list: Array[FSMState] = []

## key=StringName
## value=State
var _state_index: Dictionary = {}

var _transition_list: Array[FSMTransition] = []

var xr_viewport: XRToolsViewport2DIn3D : set=set_xr_viewport

## key=StringName
## value=Callable
var _event_connections: Dictionary

static var null_state := FSMState.new("__null__")

func _init() -> void:
	#build_fsm()
	build_from_graph_resource(FSM_GRAPH)

# TODO static
func build_from_graph_resource(fsm_graph_resource: FSMGraphResource) -> ApplicationStateMachine:
	var application_state_machine := self #ApplicationStateMachine.new()
	
	## key=FSMStateResource
	## value=FSMState
	var fsm_state_resource_map: Dictionary
	
	for fsm_state_resource: FSMStateResource in fsm_graph_resource.states:
		var fsm_state: FSMState
		if fsm_state_resource.scene:
			fsm_state = FSMViewState.new(fsm_state_resource.get_runtime_id(), fsm_state_resource.scene) 
		else:
			fsm_state = FSMState.new(fsm_state_resource.get_runtime_id()) 
		#print("runtime_id: ", fsm_state_resource.get_runtime_id())
		application_state_machine.add_state(fsm_state)
		
		for fsm_event_slot_resource:FSMEventSlotResource in fsm_state_resource.event_slots:
			fsm_state.add_event(fsm_event_slot_resource.id)
		
		# start with the initial state
		if fsm_state_resource.inital:
			_current_state = fsm_state
			
		for fsm_event_mapping_resource:FSMEventMappingResource in fsm_state_resource.event_mappings:
			fsm_state.add_event_mapping(fsm_event_mapping_resource.from_event, fsm_event_mapping_resource.to_event)
		
		# add state resource to a map to find them later while connecing with transitions
		fsm_state_resource_map[fsm_state_resource] = fsm_state
	
	for fsm_transition_resource:FSMTransitionResource in fsm_graph_resource.transitions:
		var fsm_transition := FSMTransition.new()
		fsm_transition.from_state = fsm_state_resource_map[fsm_transition_resource.from_state]
		fsm_transition.to_state = fsm_state_resource_map[fsm_transition_resource.to_state]
		fsm_transition.event_id = fsm_transition_resource.from_event_slot.id
		add_transition(fsm_transition)
	
	return application_state_machine


func add_state(state: FSMState):
	_state_list.append(state)
	_state_index[state.id] = state

func get_state(id: String) -> FSMState:
	var state: FSMState = _state_index.get(id, null_state)
	
	if state == null_state:
		push_warning("Try to get an not existing State: ", id)
	
	return state

func add_transition(transition: FSMTransition):
	_transition_list.append(transition)
	
# TODO: this is a problem as I don't like to use XRToolsViewport2DIn3D in the FSMGraph addon.
# TODO: define a facade layer!
func set_xr_viewport(xr_viewport_param: XRToolsViewport2DIn3D):
	xr_viewport = xr_viewport_param

	
func push(event_id: StringName):
	#print("event: ", event_id)
	#print("state before: ", _current_state.id)
	travel_event(event_id)
	#print("state after: ", _current_state.id)
	
func travel_event(event_id: StringName):
	#var event := FSMEvent.new(event_id)
	
	#print("_current_state: ", _current_state.id)
	var fsm_event := _current_state.get_event(event_id)
	var mapped_id := fsm_event.id
	#print("mapped_id: ", mapped_id)
	
	# signal each event instance (the input and the mapped output)
	# but only if they've a valid event
	if fsm_event != FSMEvent.null_event:
		fsm_event.matched.emit()
		var mapped_fsm_event := FSMEvent.new(mapped_id)
		if mapped_fsm_event != FSMEvent.null_event:
			mapped_fsm_event.matched.emit()
	
	# call the connected event state local before traveling
	if _event_connections.has(mapped_id):
			print("call event hook: ", mapped_id)
			_event_connections[mapped_id].call()
	
	for transition: FSMTransition in _transition_list:
		#print("_current_state: ", _current_state.id)
		if transition.from_state == _current_state:
			#print("correct from state: ", _current_state.id)
			
			## event_id.is_empty() is the 'default' transition
			if transition.event_id == mapped_id or transition.event_id.is_empty():
				
				_current_state.exited.emit()
				
				print("change state to: ", transition.to_state.id)
				# change current state - this is traveling the Transition
				_current_state = transition.to_state
				
				if _current_state is FSMViewState:
					if xr_viewport:
						xr_viewport.scene = _current_state.scene
						# TODO: put that theme stuff into the XRToolsViewport2DIn3D facade layer
						var control: Control = xr_viewport.get_node("Viewport").get_child(0)
						control.theme = XR_CINEMON_THEME
						xr_viewport.enabled = true
				else:
					if xr_viewport:
						xr_viewport.scene = null
						xr_viewport.enabled = false
					
				_current_state.entered.emit()
				
				if not transition.event_id.is_empty():
					# replace event.id if mapped after traveling (and not empty)
					fsm_event.id = mapped_id
					print("change mapped event: ", fsm_event.id)
		
