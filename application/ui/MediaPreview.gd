class_name MediaPreview
extends PanelContainer

var media_id: int : set=set_media_id
var image_texture: ImageTexture : set=set_image_texture

@onready var media_texture_rect: TextureRect = %MediaTextureRect

func set_media_id(media_id_param: int):
	media_id = media_id_param
	
func set_image_texture(tex: ImageTexture):
	image_texture = tex
	media_texture_rect.texture = image_texture
	
func restore_image_texture():
	media_texture_rect.texture = image_texture
	
func set_media_texture(tex: Texture2D):
	media_texture_rect.texture = tex

func _on_pressed() -> void:
	FSMEventGateway.push("travel_video_player")
	
	# TBD: only debug code
	#var md := Services.media_library_controller.media_library.get_media_descriptor(media_id)
		
	IntentDispatcher.handle_intent(Intent.SelectMedia.new(media_id))
	IntentDispatcher.handle_intent(Intent.Play.new())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_pressed()
			
			accept_event() # stops propagating the click
