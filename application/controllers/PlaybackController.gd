class_name PlaybackController
extends Node

signal playback_time_changed(current: float, total: float)

@export var video_stream_player: VideoStreamPlayer
@export var preview_video_stream_player: VideoStreamPlayer

var _delta_timer := 0.0

func _ready() -> void:
	register_service_controller()
	
	FSMEventGateway.get_state("video_player_3").get_event("video_navigation").matched.connect(_on_fsm_event_video_navigation)
	
func _process(delta: float) -> void:
	_delta_timer += delta
	
	if _delta_timer >= 1.0:
		_delta_timer -= 1.0
		if video_stream_player.is_playing():
			var current_time = video_stream_player.stream_position
			var total_length = video_stream_player.get_stream_length()
			playback_time_changed.emit(current_time, total_length)
	
func register_service_controller():
	Services.playback_controller = self
	Services.preview_video_stream_player = preview_video_stream_player

## Public getter API ##
## prefix: get_*
## these functions are public getters and could be used from outside (e.g. the UI)

func get_current_playtime() -> float:
	var time: float
	time = video_stream_player.stream_position
	return time
	
func get_total_playtime() -> float:
	var time: float
	time = video_stream_player.get_stream_length()
	return time

## Friend Intent API ##
## prefix: handle_*
## these functions are only called by the IntentDispatcher and shouldn't be called from other ouside places
## consider them as friend to IntentDispatcher

func handle_select_media_intent(intent: Intent.SelectMedia):
	exec_set_file_stream(intent.id)

func handle_play_intent(_intent: Intent.Play):
	exec_play()

func handle_stop_intent(_intent: Intent.Stop):
	exec_stop() 
	
func handle_pause_intent(_intent: Intent.Pause):
	exec_pause()
	
func handle_seek_absolute_position(intent: Intent.SeekAbsolutePosition):
	exec_seek_absolute(intent.playback_position)
	
## Internal Exec API ##
## prefix: exec_*
## these functions are only called from inside this class and shouldn't be called from outside

func exec_play():
	if not video_stream_player.is_playing():
		video_stream_player.play()
	video_stream_player.set_paused(false)
	
func exec_pause():
	video_stream_player.set_paused(true)
	
func exec_stop():
	video_stream_player.stop()
	Services.media_library_controller.selected_media_descriptor = null

func exec_set_file_stream(media_id: int):
	var media_library := Services.media_library_controller.media_library

	var found_media_id := media_library.media_descriptors.find_custom(func(a): return a.id == media_id)
	if found_media_id == -1:
		return
	
	var md: MediaDescriptor = media_library.media_descriptors[found_media_id]
	var path = md.path
	md.last_played = Time.get_unix_time_from_system()
	md.play_count += 1
	
	print("play: ", path)
	video_stream_player.stream.file = path

	Services.media_library_controller.selected_media_descriptor = md
	
func exec_seek_relative(time: float):
	if video_stream_player.get_stream_length() - time <= 0:
		video_stream_player.stream_position = 0
	else:
		video_stream_player.stream_position += time
	
func exec_seek_absolute(time: float):
	var seek_pos := clampf(time, 0.0, video_stream_player.get_stream_length())
	video_stream_player.stream_position = seek_pos
	
## FSM Signal Handlers ##
## prefix: _on_fsm_event_*
## these functions are internal signal handlers for FSM events
	
func _on_fsm_event_video_navigation():
	var navigation_position := FSMEventGateway.get_vector2_variable("navigation_position")
	print("navigation_position: ", navigation_position)
	
	var seek_time := 10.0 # seconds

	if navigation_position.x > 0:
		exec_seek_relative(seek_time)
	elif navigation_position.x <= 0:
		exec_seek_relative(-seek_time)
