class_name SpaceController
extends Node

const DEFAULT_ENV = preload("uid://er867l7dl10j")

@export var xr_camera: XRCamera3D
@export var xr_origin: XROrigin3D
@export var world: Node3D
@export var video_stream_player: VideoStreamPlayer
@export var space_character: XRToolsPlayerBody
@export var sphere_renderer: SphereRenderer

var active_space: Space
var spatial_projection := SpatialProjection.new()

var space_rotate_angle := PI / 20.0

func _ready() -> void:
	register_service_controller()
		
	FSMEventGateway.get_state("video_player_3").get_event("grip_left").matched.connect(_on_fsm_event_grib_left)
	FSMEventGateway.get_state("video_player_3").get_event("grip_right").matched.connect(_on_fsm_event_grib_right)
	
		
func _process(delta: float) -> void:
	# always place the space sphere exact around XR camera
	if spatial_projection.type == SpatialProjection.Type.SPHERE: 
		active_space.update_sphere_position(xr_camera.global_position)
		
func register_service_controller():
	Services.space_controller = self
	Services.spatial_anchor_service.camera = xr_camera

## Friend Intent API ##
## prefix: handle_*
## these functions are only called by the IntentDispatcher and shouldn't be called from other ouside places
## consider them as friend to IntentDispatcher
	
func handle_select_space_intent(intent: Intent.SelectSpace):
	exec_change_space_scene(intent.space_scene)
	exec_connect_video_texture()
	
	
func handle_select_media_intent(intent: Intent.SelectMedia):
	var media_projection: MediaProjection = Services.media_library_controller.selected_media_descriptor.media_projection
	exec_change_media_projection(media_projection)
	
	exec_connect_video_texture()

func handle_change_spatial_projection_intent(intent: Intent.ChangeSpatialProjection):
	exec_change_spatial_projection(intent.spatial_projection)
	if Services.media_library_controller.selected_media_descriptor:
		var media_projection: MediaProjection = Services.media_library_controller.selected_media_descriptor.media_projection
		exec_change_media_projection(media_projection)
	
	exec_connect_video_texture()

func handle_change_media_projection_intent(intent: Intent.ChangeMediaProjection):
	exec_change_media_projection(intent.media_projection)
	exec_connect_video_texture()

func handle_calibrate_space_character_height(intent: Intent.CalibrateSpaceCharacterHeight):
	space_character.player_calibrate_height = true

func handle_rotate_sphere_media_view(intent: Intent.RotateSphereMediaView):
	sphere_renderer.rotate_sphere_media_view(intent.rotate_by, intent.reset_view)
	
func handle_stop_intent(_intent: Intent.Stop):
	active_space.set_canvas_color_override(true)
	
## Internal Exec API ##
## prefix: exec_*
## these functions are only called from inside this class and shouldn't be called from outside

func exec_reset_inital_position():
	space_character.enabled = false
	
	space_character.global_position = Vector3.ZERO
	xr_origin.global_position = active_space.get_inintial_position() 
	
	# activate physics movement while in flat mode
	if spatial_projection.type == SpatialProjection.Type.FLAT: 
		space_character.enabled = true

func exec_change_space_scene(space_scene: PackedScene):
	if active_space:
		active_space.queue_free()
		
	active_space = space_scene.instantiate()
	world.add_child(active_space)
	exec_reset_inital_position()
	
	if active_space.environment:
		xr_camera.environment = active_space.environment
	else:
		xr_camera.environment = DEFAULT_ENV

func exec_change_spatial_projection(spatial_projection_param: SpatialProjection):
	spatial_projection = spatial_projection_param
	active_space.change_spatial_projection(spatial_projection_param)
	exec_reset_inital_position()
	
func exec_change_media_projection(media_projection_param: MediaProjection):
	active_space.change_media_projection(media_projection_param)

func exec_connect_video_texture():
	var video_texture := video_stream_player.get_video_texture()
	if !video_texture:
		return
		
	# do not connect a texture if no media is selected
	if not Services.media_library_controller.selected_media_descriptor:
		return
		
	var final_texture: Texture2D
		
	## if the video is a VR video and we try to render it on a flat surface put it through the SphereRenderer
	if Services.media_library_controller.selected_media_descriptor.media_projection.vr_coverage != MediaProjection.VRCoverage.NONE and spatial_projection.type == SpatialProjection.Type.FLAT:
		sphere_renderer.change_media_projection(Services.media_library_controller.selected_media_descriptor.media_projection)
		sphere_renderer.set_video_texture(video_texture)
		final_texture = sphere_renderer.get_rendered_texture()
		if active_space:
			## TODO: use MONO mode on the "second shader pass" if VR videos are played on flat surface.
			## Maybe it is possible to render VR video on a flat surface, but needs more work
			active_space.active_canvas.set_stereo_format(MediaProjection.StereoFormat.MONO)
	else:
		final_texture = video_texture
	
	if active_space:
		active_space.active_canvas.set_video_texture(final_texture)
		active_space.set_canvas_color_override(false)
	

## FSM Signal Handlers ##
## prefix: _on_fsm_event_*
## these functions are internal signal handlers for FSM events

func _on_fsm_event_grib_left():
	xr_origin.rotate_y(space_rotate_angle)

func _on_fsm_event_grib_right():
	xr_origin.rotate_y(-space_rotate_angle)
