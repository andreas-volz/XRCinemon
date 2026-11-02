@tool
extends Node3D

## some test cases from:
## https://naver.github.io/egjs-view360/docs/projections/eac

@export var test_texture: Texture2D : set=set_test_texture

@onready var cube: MeshInstance3D = $Cube
@onready var sphere: MeshInstance3D = $Sphere

func set_test_texture(texture: Texture2D):
	test_texture = texture
	
	var texel_size: Vector2
	texel_size.x = 1.0 / test_texture.get_width()
	texel_size.y = 1.0 / test_texture.get_height()
	
	cube.mesh.material.set_shader_parameter("video_texture", test_texture)
	sphere.mesh.material.set_shader_parameter("video_texture", test_texture)
	
	print("textel_size: ", texel_size)
	cube.mesh.material.set_shader_parameter("texel_size", texel_size)
	sphere.mesh.material.set_shader_parameter("texel_size", texel_size)
	
