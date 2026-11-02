@tool
class_name VideoCanvasPlane
extends VideoCanvasFlat

## if needed provide a user specific scale that is multiplied on the scale as last step
## this might be helpfull to lower the video size on the same display size or to zoom in
var user_scale: float = 1.0 # TODO: provide this as @export?

@export var canvas_size := Vector2(2.0, 2.0) : set=set_canvas_size




func _ready() -> void:
	fit_mode = VideoCanvas.FitMode.CONTAIN
	
func set_video_texture(texture: Texture2D):
	# TODO: think about to make this [0..1] based and not [-0.5...+0.5]
	var half_display_fraction := 0.5
	var theta := Vector2(-half_display_fraction, half_display_fraction)
	
	set_view_range_theta(theta)

	video_texture = texture
	mesh.material.set_shader_parameter("video_texture", video_texture)
	if texture == null:
		return
		
	var video_aspect := get_video_aspect()
	var geometry_aspect := get_geometry_aspect()
	
	var fit_scale_local: Vector2

	var display_scale_x: float = 1.0 # always use the complete display geometry for plane
	if fit_mode == VideoCanvas.FitMode.STRETCH:
		fit_scale_local = Vector2(display_scale_x, 1.0)
	elif fit_mode == VideoCanvas.FitMode.CONTAIN:
		var video_width_fraction := video_aspect / geometry_aspect
		if video_aspect > geometry_aspect:
			# Video is wider than the mesh -> fit height
			var fit_x := display_scale_x
			var fit_y := video_width_fraction
			fit_scale_local = Vector2(fit_x, fit_y)
		else:
			# Video is narrower than the mesh -> fit width
			var fit_x := display_scale_x / video_width_fraction
			var fit_y := 1.0
			fit_scale_local = Vector2(fit_x, fit_y);
	elif fit_mode == VideoCanvas.FitMode.COVER:
		pass
	
	fit_scale = fit_scale_local * (1.0 / user_scale)
	set_corner_radius(corner_radius)
	#print("resolution: ", video_texture.get_size())

func get_mesh_size() -> Vector2:
	return mesh.size

func get_geometry_aspect() -> float:
	var aspect: float = float(get_mesh_size().x) / float(get_mesh_size().y)
	return aspect



func set_canvas_size(size: Vector2):
	canvas_size = size
	mesh.size = size
	set_video_texture(video_texture)
	set_corner_radius(corner_radius)
	
