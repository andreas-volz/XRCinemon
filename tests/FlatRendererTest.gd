extends PanelContainer

const TEST = preload("uid://b8dnm13pnfyyh")
const EAC_TEMPLATE = preload("uid://clk87ryh6ucnq")

@onready var output_texture: TextureRect = %OutputTexture
@onready var flat_renderer: FlatRenderer = %FlatRenderer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flat_renderer.set_video_texture(EAC_TEMPLATE)
	output_texture.texture = flat_renderer.get_rendered_texture()
	print("rendered size: ", output_texture.texture.get_size())


func _on_save_button_pressed() -> void:
	var image := output_texture.texture.get_image()
	image.save_png(("user://test/flat_renderer_test.png"))
