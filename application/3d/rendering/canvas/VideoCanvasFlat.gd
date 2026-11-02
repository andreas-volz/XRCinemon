## VideoCanvasFlat is only an interface base class and shouldn't be instanciated
class_name VideoCanvasFlat
extends VideoCanvas

@export var corner_radius: float : set=set_corner_radius
@export var letterbox_mode := LetterboxMode.COLOR : set=set_letterbox_mode

var fit_scale := Vector2.ONE : set=set_fit_scale

func set_letterbox_mode(mode: LetterboxMode):
	letterbox_mode = mode
	mesh.material.set_shader_parameter("letterbox_mode", mode)
	set_corner_radius(corner_radius)
	
## only API interface - should never be called in this class
## need to override!
func get_geometry_aspect() -> float:
	assert(false)
	return 0.0
	
func get_video_aspect() -> float:
	if video_texture == null:
		# if no video (yet) available assume it fills the complete geometry
		return get_geometry_aspect()
	var video_w = video_texture.get_width()
	var video_h = video_texture.get_height()
	var video_aspect := float(video_w) / float(video_h)
	return video_aspect
	
## only API interface - should never be called in this class
## need to override!
func get_mesh_size() -> Vector2:
	assert(false)
	return Vector2.ZERO
	
func set_corner_radius(corner_radius_param: float):
	corner_radius = corner_radius_param
	var mesh_size: Vector2 = get_mesh_size()
	
	var video_size := get_video_size()
		
	var corner_elipse: Vector2
	
	if letterbox_mode == LetterboxMode.COLOR:
		corner_elipse = Vector2(mesh_size.y, mesh_size.x)
	elif letterbox_mode == LetterboxMode.DISCARD:
		corner_elipse = Vector2(video_size.y, video_size.x)

	mesh.material.set_shader_parameter("corner_size", corner_elipse.normalized() * corner_radius)

func set_fit_scale(value: Vector2):
	fit_scale = value
	mesh.material.set_shader_parameter("fit_scale", value)
