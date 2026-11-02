class_name Space
extends Node3D

@export var flat_canvas: VideoCanvas
@export var sphere_canvas: VideoCanvas
@export var models: Node3D
@export var initial_position: Marker3D

@export var canvas_override_color: Color

@export var environment: Environment

@onready var active_canvas: VideoCanvas = flat_canvas

# TODO this is not good. better make a concept for all UI access in the Space
@onready var vr_flat_control_screen: XRToolsViewport2DIn3D = %VRFlatControlScreen

func _ready() -> void:
	set_canvas_color_override(true)

func get_inintial_position() -> Vector3:
	if initial_position:
		return initial_position.global_position
	return Vector3.ZERO
	
func set_canvas_color_override(value: bool):
	if flat_canvas:
		flat_canvas.set_color_override(value, canvas_override_color)
	if sphere_canvas:
		sphere_canvas.set_color_override(value, canvas_override_color)

func change_spatial_projection(spatial_projection: SpatialProjection):
	if spatial_projection.type == SpatialProjection.Type.FLAT: 
		if flat_canvas:
			active_canvas = flat_canvas
			flat_canvas.visible = true
			models.visible = true
		if sphere_canvas:
			sphere_canvas.visible = false
	if spatial_projection.type == SpatialProjection.Type.SPHERE: 
		if sphere_canvas:
			sphere_canvas.set_srgb_conversion(true)
			active_canvas = sphere_canvas
			models.visible = false
			sphere_canvas.visible = true
		if flat_canvas:
			flat_canvas.visible = false
			
		

		
func change_media_projection(media_projection: MediaProjection):
	active_canvas.change_media_projection(media_projection)
	
	# show the UI to navigate in a VR video only in VR mode
	# this is anyhow only visible for flat projections as the UI is below the sphere canvas
	# HACK
	if vr_flat_control_screen:
		if media_projection.vr_coverage == MediaProjection.VRCoverage.NONE:
			vr_flat_control_screen.visible = false
			vr_flat_control_screen.enabled = false
		else:
			vr_flat_control_screen.visible = true
			vr_flat_control_screen.enabled = true

func update_sphere_position(sphere_pos: Vector3):
	if sphere_canvas:
		sphere_canvas.global_position = sphere_pos
