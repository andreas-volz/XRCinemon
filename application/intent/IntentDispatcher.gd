#class_name IntentDispatcher
extends Node

#var playback_controller: PlaybackController
#var space_controller: SpaceController
#var media_library_controller: MediaLibraryController

func handle_intent(intent: Intent):
	# development assert to ensure correct initialization phase
	assert(Services.playback_controller != null)
	assert(Services.space_controller != null)
	assert(Services.media_library_controller != null)

	if intent is Intent.SelectMedia:
		Services.playback_controller.handle_select_media_intent(intent)
		Services.space_controller.handle_select_media_intent(intent)
	elif intent is Intent.Play:
		Services.playback_controller.handle_play_intent(intent)
	elif intent is Intent.Stop:
		Services.playback_controller.handle_stop_intent(intent)
		Services.space_controller.handle_stop_intent(intent)
	elif intent is Intent.Pause:
		Services.playback_controller.handle_pause_intent(intent)
	elif intent is Intent.SelectSpace:
		Services.space_controller.handle_select_space_intent(intent)
	elif intent is Intent.ChangeSpatialProjection:
		Services.space_controller.handle_change_spatial_projection_intent(intent)
	elif intent is Intent.ChangeMediaProjection:
		Services.space_controller.handle_change_media_projection_intent(intent)
	elif intent is Intent.ScanMediaLibrary:
		Services.media_library_controller.handle_scan_media_library(intent)
	elif intent is Intent.SeekAbsolutePosition:
		Services.playback_controller.handle_seek_absolute_position(intent)
	elif intent is Intent.CalibrateSpaceCharacterHeight:
		Services.space_controller.handle_calibrate_space_character_height(intent)
	elif intent is Intent.RotateSphereMediaView:
		Services.space_controller.handle_rotate_sphere_media_view(intent)
