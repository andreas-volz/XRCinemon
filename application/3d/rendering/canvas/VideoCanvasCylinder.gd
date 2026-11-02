@tool
class_name VideoCanvasCylinder
extends VideoCanvasFlat

## Physical curvature radius of the display surface (in meter).
## This defines the circle radius of the curved display (e.g. 1000R = 1 m).
@export var display_radius: float = 1.0 : set=set_display_radius

## Physical display height measured vertically from bottom to top edge (in meter).
## The display is flat in the vertical direction.
@export var display_height: float = 1.0 : set=set_display_height

## Physical display width measured from edge to edge (chord width).
## This is the "Sehnenbreite" — the straight-line distance between the display edges,
## not the arc length along the curved surface.
@export var display_width: float = 1.0 : set=set_display_width

## Converts the chord width into the corresponding arc length of the curved surface.
## Based on the circle's chord-angle relationship and the arc length formula b = r * angle.
var display_arc_length: float

## Circumference of the complete 360° cylinder projection.
## Used as the total horizontal extent of the curved surface.
var cylinder_circumference: float

## Fraction of the full cylinder circumference occupied by the physical display.
## A value of 1.0 represents the complete 360° cylinder.
var display_arc_fraction: float

## if needed provide a user specific scale that is multiplied on the scale as last step
## this might be helpfull to lower the video size on the same display size or to zoom in
var user_scale: float = 1.0 # TODO: provide this as @export

func _ready() -> void:
	#mesh.top_radius = display_radius
	#mesh.bottom_radius = display_radius
	#mesh.height = display_height

	fit_mode = VideoCanvas.FitMode.CONTAIN
	
	# Workaround for transparency sorting issues between the cylinder canvas and XRTools UI.
	# Keep render_priority low to prevent the cylinder's backface from interfering with UI rendering.
	mesh.material.render_priority = -100
	
func _calculate_internal_sizes():
	display_arc_length = 2.0 * display_radius * asin(display_width / (2.0 * display_radius))
	cylinder_circumference = 2.0 * PI * display_radius
	display_arc_fraction = display_arc_length / cylinder_circumference
	set_video_texture(null)
	
	
func set_video_texture(texture: Texture2D):
	
	# TODO: think about to make this [0..1] based and not [-0.5...+0.5]
	var half_display_arc_fraction := display_arc_fraction * 0.5
	var theta := Vector2(-half_display_arc_fraction, half_display_arc_fraction)
	
	set_view_range_theta(theta)
	
	# from here on need texture
	if texture == null:
		return
		
	video_texture = texture
	
	var video_aspect := get_video_aspect()
	var geometry_aspect := get_geometry_aspect()
	
	#print("video_aspect: ", video_aspect)
	#print("geometry_aspect: ", geometry_aspect)
	#print("display_arc_length: ", display_arc_length)
	#print("cylinder_circumference: ", cylinder_circumference)
	#print("display_arc_fraction: ", display_arc_fraction)
	
	mesh.material.set_shader_parameter("uv_normalization", Vector2(1.0, 2.0)) # to normalize the cap and bottom away
	
	mesh.material.set_shader_parameter("video_texture", video_texture)
	
	var fit_scale_local: Vector2

	var display_scale_x := 1.0 / display_arc_fraction
	if fit_mode == VideoCanvas.FitMode.STRETCH:
		fit_scale_local = Vector2(display_scale_x, 1.0)
	elif fit_mode == VideoCanvas.FitMode.CONTAIN:
		var video_width_fraction := video_aspect / geometry_aspect
		
		if video_aspect > geometry_aspect:
			# video wider -> fit height
			var fit_x := display_scale_x
			var fit_y := video_width_fraction
			fit_scale_local = Vector2(fit_x, fit_y)
		else:
			# video smaller -> fit width
			var fit_x := display_scale_x / video_width_fraction
			var fit_y := 1.0
			fit_scale_local = Vector2(fit_x, fit_y);
	elif fit_mode == VideoCanvas.FitMode.COVER:
		pass
	
	fit_scale = fit_scale_local * (1.0 / user_scale)
	
	set_corner_radius(corner_radius)
	
func get_mesh_size() -> Vector2:
	return Vector2(display_width, display_height) / fit_scale

func get_geometry_aspect() -> float:
	var aspect: float = display_arc_length / display_height
	
	return aspect

func set_display_radius(value: float):
	display_radius = value
	mesh.top_radius = display_radius
	mesh.bottom_radius = display_radius
	_calculate_internal_sizes()
	
func set_display_height(value: float):
	display_height = value
	mesh.height = display_height
	_calculate_internal_sizes()
	
func set_display_width(value: float):
	display_width = value
	_calculate_internal_sizes()
