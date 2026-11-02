class_name SphereRenderer
extends Node3D

const VIDEO_SPHERE_PROJECTION = preload("uid://b0olldmgkv6ao")

@onready var video_canvas_sphere: VideoCanvasSphere = %VideoCanvasSphere
@onready var camera_3d: Camera3D = %Camera3D
@onready var sub_viewport: SubViewport = %SubViewport

func _ready() -> void:
	video_canvas_sphere.mesh = SphereMesh.new()
	video_canvas_sphere.sphere_radius = 50.0
	video_canvas_sphere.mesh.material = ShaderMaterial.new()
	video_canvas_sphere.mesh.material.shader = VIDEO_SPHERE_PROJECTION

func set_video_texture(input_texture: Texture2D):
	if input_texture != null:
		sub_viewport.size = input_texture.get_size()
	
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	video_canvas_sphere.set_video_texture(input_texture)
	
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
	video_canvas_sphere.set_srgb_conversion(value)

func change_media_projection(media_projection: MediaProjection):
	video_canvas_sphere.change_media_projection(media_projection)

func rotate_sphere_media_view(rotate_by: Vector3, reset_view: bool):
	print("rotate: ", rotate_by)
	if reset_view:
		camera_3d.rotation = Vector3.ZERO
	else:
		camera_3d.rotation += rotate_by
