class_name  MediaLibraryController
extends Node

var media_library := MediaLibrary.new()
var selected_media_descriptor: MediaDescriptor
var sort_mode: MediaLibrary.SortMode = MediaLibrary.SortMode.TITLE
var sort_descending: bool = false

@export var video_stream_player: VideoStreamPlayer

func _ready() -> void:
	register_service_controller()
	media_library.startup()
	
func register_service_controller():
	Services.media_library_controller = self

## Friend Intent API ##
## prefix: handle_*
## these functions are only called by the IntentDispatcher and shouldn't be called from other ouside places
## consider them as friend to IntentDispatcher

func handle_scan_media_library(intent: Intent.ScanMediaLibrary):
	exec_scan_media_libray(intent.recreate, intent.guess_tags)

## Internal Exec API ##
## prefix: exec_*
## these functions are only called from inside this class and shouldn't be called from outside

func exec_scan_media_libray(recreate: bool, guess_tags: bool):
	IntentDispatcher.handle_intent(Intent.Stop.new())
	media_library.scan_media_libray(recreate, guess_tags)


	
