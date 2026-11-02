class_name VideoCanvas
extends MeshInstance3D

enum FitMode {
	STRETCH = 0, ## Fill the entire display, ignoring aspect ratio.
	CONTAIN = 1, ## Preserve aspect ratio and fit entirely within the display.
	COVER = 2    ## Preserve aspect ratio and completely cover the display, cropping if necessary.
}

enum LetterboxMode {
	DISCARD = 0,
	COLOR = 1
}

var video_texture: Texture2D : set=set_video_texture
var fit_mode: FitMode

func change_media_projection(media_projection: MediaProjection):
	set_stereo_format(media_projection.stereo_format)
	set_projection_format(media_projection.projection_format)
	
	if media_projection.vr_coverage == MediaProjection.VRCoverage.NONE:
		set_view_range_theta(Vector2(0.0, 1.0))
		set_projection_scale(Vector2(1.0, 1.0))
	elif media_projection.vr_coverage == MediaProjection.VRCoverage.HALF_SPHERE:
		set_view_range_theta(Vector2(0.25, 0.75))
		set_projection_scale(Vector2(2.0, 1.0))
	elif media_projection.vr_coverage == MediaProjection.VRCoverage.FULL_SPHERE:
		set_view_range_theta(Vector2(0.0, 1.0))
		set_projection_scale(Vector2(1.0, 1.0))
		

func set_stereo_format(stereo_format: MediaProjection.StereoFormat):
	mesh.material.set_shader_parameter("stereo_format", stereo_format)

## only API interface - should never be called in this class
## need to override!
func set_video_texture(_texture: Texture2D):
	assert(false)
	
func get_video_texture() -> Texture2D:
	if mesh == null:
		return null
	return mesh.material.get_shader_parameter("video_texture")
	
func set_view_range_theta(theta: Vector2):
	mesh.material.set_shader_parameter("view_range_theta", theta)
	
func set_projection_format(projection_format: MediaProjection.ProjectionFormat):
	mesh.material.set_shader_parameter("projection_format", projection_format)
	
func set_projection_scale(value: Vector2):
	mesh.material.set_shader_parameter("projection_scale", value)
	
func set_srgb_conversion(value: bool):
	mesh.material.set_shader_parameter("texture_is_srgb", value)

func set_color_override(force: bool, color: Color = Color.WHITE):
	if mesh:
		mesh.material.set_shader_parameter("force_color_override", force)
		mesh.material.set_shader_parameter("override_color", color)

func get_video_size() -> Vector2:
	if video_texture:
		var video_w = video_texture.get_width()
		var video_h = video_texture.get_height()
		return Vector2(video_w, video_h)
	return Vector2.ZERO

func show_empty_canvas(value: bool):
	set_color_override(value, Color.DIM_GRAY)
	
