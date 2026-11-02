class_name Intent
extends RefCounted

## Base class for all application Intents.
##
## An Intent describes what the user wants to change, not how the change
## is performed. Intents are dispatched to the ApplicationController,
## which applies the requested modification to the ApplicationContext.
##
## Use Intents for application state changes.
##
## Typical flow:
## UI -> Intent -> ApplicationController -> ApplicationContext -> Signals

## Pauses the current media playback.
class Pause extends Intent:
	pass

## Starts or resumes the current media playback.
class Play extends Intent:
	pass
	
## Stops the current media playback.
class Stop extends Intent:
	pass

## Selects a media item by its unique ID.
class SelectMedia extends Intent:
	var id: int

	func _init(id_param: int) -> void:
		id = id_param

## Selects the Space in which the media is presented.
class SelectSpace extends Intent:
	var space_scene: PackedScene

	func _init(space_scene_param: PackedScene) -> void:
		space_scene = space_scene_param
		
## Changes whcih display is used as active display (e.g. Sphere or Flat)
class ChangeSpatialProjection extends Intent:
	var spatial_projection: SpatialProjection
	
	func _init(spatial_projection_param: SpatialProjection) -> void:
		spatial_projection = spatial_projection_param
		
## Changes how the media is projected onto the active display (e.g. Stereo, EAC, 180°,...)
class ChangeMediaProjection extends Intent:
	var media_projection: MediaProjection
	
	func _init(media_projection_param: MediaProjection) -> void:
		media_projection = media_projection_param

## Scan for new Media Descriptors or recreates existing for the specified path or the entire media library.
class ScanMediaLibrary extends Intent:
	## If no path is given, update previews for all paths provided in the MediaLibrary configuration.
	var path := OptionalString.new()
	
	## Force recreation of all previews, even if they already exist. Otherwise generate only missing previews.
	var recreate: bool = false
	
	var guess_tags: bool = false

## Seek the current loaded Media to an absolute position
class SeekAbsolutePosition extends Intent:
	var playback_position: float
	
	func _init(playback_position_param: float):
		playback_position = playback_position_param

## Ask the XRToolsPlayerBody (which is a CharacterBody3D) to calibrate it's physical height
## e.g. if you start laying on the floor and meanwhile have another strange position
class CalibrateSpaceCharacterHeight extends Intent:
	pass
	
## In case a VR video (180°/360°) is projected on a flat surface this clipping could be rotated along it's x/y asis
class RotateSphereMediaView extends Intent:
	var rotate_by: Vector3 = Vector3.ZERO
	var reset_view: bool = false
	
	func _init(rotate_by_param: Vector2 = Vector2.INF, reset_view_param: bool = false):
		rotate_by.x = rotate_by_param.x
		rotate_by.y = rotate_by_param.y
		reset_view = reset_view_param
