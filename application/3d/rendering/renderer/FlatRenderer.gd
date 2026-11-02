class_name FlatRenderer
extends Node3D

const VIDEO_PLANE_PROJECTION = preload("uid://dk878kx4c1v0f")

@onready var sub_viewport: SubViewport = %SubViewport
@onready var video_canvas_plane: VideoCanvasPlane = %VideoCanvasPlane

func _ready() -> void:
	var plane_mesh := PlaneMesh.new()
	video_canvas_plane.mesh = plane_mesh
	
	plane_mesh.material = ShaderMaterial.new()
	plane_mesh.material.shader = VIDEO_PLANE_PROJECTION
	plane_mesh.orientation = PlaneMesh.FACE_Z
	plane_mesh.material.set_shader_parameter("horizontal_mirror", true)
	video_canvas_plane.set_view_range_theta(Vector2(-0.5, 0.5))
	plane_mesh.material.set_shader_parameter("letterbox_mode", 0)
	
	# set to a fixed size to allow the camera to get the complete texture
	video_canvas_plane.canvas_size = Vector2(10.0, 10.0)

func set_video_texture(input_texture: Texture2D):
	if input_texture != null:
		sub_viewport.size = input_texture.get_size()
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE

	video_canvas_plane.set_video_texture(input_texture)
	
func get_rendered_texture() -> Texture2D:
	return sub_viewport.get_texture()

func render_preview(input_texture: Texture2D) -> Image:
	set_video_texture(input_texture)
	

	# this renders only one frame and waits until it's drawn before continue
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	
	var image = sub_viewport.get_texture().get_image()
	
	return image
	
func set_srgb_conversion(value: bool):
	video_canvas_plane.set_srgb_conversion(value)

func change_media_projection(media_projection: MediaProjection):
	video_canvas_plane.change_media_projection(media_projection)
