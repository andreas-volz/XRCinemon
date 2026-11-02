@tool
class_name VideoCanvasSphere
extends VideoCanvas

@export var sphere_radius: float = 0.5 : set=set_sphere_radius

func set_video_texture(texture: Texture2D):
	video_texture = texture
	
	mesh.material.set_shader_parameter("video_texture", video_texture)
	
func set_view_range_phi(phi: Vector2):
	mesh.material.set_shader_parameter("view_range_phi", phi)

func set_sphere_radius(radius_param: float):
	if mesh and mesh is SphereMesh:
		sphere_radius = radius_param
		mesh.radius = radius_param
		mesh.height = radius_param * 2.0
