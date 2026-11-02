#class_name Services
extends Node

var playback_controller: PlaybackController
var space_controller: SpaceController
var media_library_controller: MediaLibraryController
var ui_controller: UIController

var preview_video_stream_player: VideoStreamPlayer

var spatial_anchor_service := SpatialAnchorService.new()	
	
