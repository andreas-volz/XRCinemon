class_name UIController
extends Node

const CINEMA_SPACE = preload("uid://cuc2sbx774i8w")

@export var viewport_screen: XRToolsViewport2DIn3D
@export var main_ui_spatial_placer: SpatialPlacer
@export var fsm_graph_test: FSMGraphResource # TEST only to develop the FSM addon

var current_ui_scene: Control

			
func _ready() -> void:
	register_service_controller()
	
	#set_main_ui_placement_strategy(main_ui_placement_strategy)
	# TODO: hard code cinema space as initial screen - better do this later in FSM
	IntentDispatcher.handle_intent(Intent.SelectSpace.new(CINEMA_SPACE))
	
	# TODO this idea was to send some dummy event and transition to the first stable State. But it doesn't work.
	#FSMEventGateway.push("__init__")
	
	# TODO: think about if a more generic registering is possible
	FSMEventGateway.set_xr_viewport(viewport_screen)
	
	FSMEventGateway.get_state("media_browser_1").entered.connect(_on_fsm_event_travel_media_browser)
	FSMEventGateway.get_state("video_player_3").entered.connect(_on_fsm_event_travel_video_player)
	FSMEventGateway.get_state("video_display_2").entered.connect(_on_fsm_event_travel_video_display)
	
	
func register_service_controller():
	Services.ui_controller = self


## Internal Exec API ##
## prefix: exec_*
## these functions are only called from inside this class and shouldn't be called from outside



## FSM Signal Handlers ##
## prefix: _on_fsm_event_*
## these functions are internal signal handlers for FSM events



func _on_fsm_event_travel_media_browser():
	pass

	
func _on_fsm_event_travel_video_player():
	pass
	
func _on_fsm_event_travel_video_display():
	main_ui_spatial_placer.placemement_strategy_floating()
	
