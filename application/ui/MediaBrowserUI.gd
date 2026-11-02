class_name MediaBrowserUI
extends PanelContainer

const MEDIA_PREVIEW = preload("uid://bp77xlwvc0car")

var list_scroll_amount := 100
var last_selected_media_preview: MediaPreview

@onready var preview_container: GridContainer = %PreviewContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var flat_renderer: FlatRenderer = $FlatRenderer
@onready var sphere_renderer: SphereRenderer = $SphereRenderer
@onready var filter_ui: FilterUI = %FilterUI
@onready var media_name: Label = %MediaName
@onready var preview_video_timer: Timer = $PreviewVideoTimer
@onready var duration_label: Label = %DurationLabel


func _ready() -> void:
	filter_ui.tags_changed.connect(_on_tags_changed)
	
	var media_library: MediaLibrary
	if Services.media_library_controller:
		media_library = Services.media_library_controller.media_library
	
		clear_preview()
		set_media(media_library.get_media_descriptors_by_tags([]))
		
		FSMEventGateway.get_state("media_browser_1").get_event("navigation").matched.connect(_on_media_browser_navigation)
	
func clear_preview():
	for child in preview_container.get_children():
		child.queue_free()
	
func set_media(media_descriptors: Array[MediaDescriptor]):
	filter_ui.set_disabled(true)
	
	clear_preview()
	
	media_descriptors = MediaLibrary.sort_by(media_descriptors, Services.media_library_controller.sort_mode, Services.media_library_controller.sort_descending)

	for media_desc: MediaDescriptor in media_descriptors:
		var media_preview: MediaPreview = MEDIA_PREVIEW.instantiate()
		preview_container.add_child(media_preview)
		media_preview.mouse_entered.connect(_on_media_preview_mouse_entered.bind(media_preview))
		media_preview.mouse_exited.connect(_on_media_preview_mouse_exited.bind(media_preview))
		
		var preview_texture := UniversalTextureLoader.load_texture(media_desc.preview)
		
		var rendered_preview_image: Image
		if media_desc.media_projection.vr_coverage == MediaProjection.VRCoverage.NONE:
			flat_renderer.change_media_projection(media_desc.media_projection)
			flat_renderer.set_srgb_conversion(false)
			rendered_preview_image = await flat_renderer.render_preview(preview_texture)
		else:
			sphere_renderer.change_media_projection(media_desc.media_projection)
			sphere_renderer.set_srgb_conversion(false)
			rendered_preview_image = await sphere_renderer.render_preview(preview_texture)
			
		var image_texture := ImageTexture.create_from_image(rendered_preview_image)
		
		media_preview.set_image_texture(image_texture)
		
		media_preview.media_id = media_desc.id
		
	filter_ui.set_disabled(false)



func scroll_list_increment(horizontal: int, vertical: int):
	scroll_container.scroll_horizontal += horizontal
	scroll_container.scroll_vertical += vertical

func _on_tags_changed():
	var array_tags := filter_ui.get_selected_tags()
	
	var media_desc_array := Services.media_library_controller.media_library.get_media_descriptors_by_tags(array_tags)
	
	
	set_media(media_desc_array)
	
func _on_media_browser_navigation():
	var navigation_position := FSMEventGateway.get_vector2_variable("navigation_position")
	
	scroll_list_increment(int(navigation_position.x * list_scroll_amount), int(-navigation_position.y * list_scroll_amount))
	

func _on_media_preview_mouse_entered(media_preview: MediaPreview):
	var media_library := Services.media_library_controller.media_library
	var md: MediaDescriptor = media_library.media_descriptors[media_preview.media_id]
	media_name.text = md.title
	duration_label.text = Utils.convert_seconds_to_string(md.duration)
	
	last_selected_media_preview = media_preview
	preview_video_timer.start()

func _on_media_preview_mouse_exited(media_preview: MediaPreview):
	preview_video_timer.stop()
	media_preview.restore_image_texture()
	media_name.text = ""
	duration_label.text = ""
	if Services.preview_video_stream_player:
		Services.preview_video_stream_player.stop()
		flat_renderer.set_video_texture(null)
		sphere_renderer.set_video_texture(null)

func _on_preview_video_timer_timeout() -> void:
	if Services.preview_video_stream_player and last_selected_media_preview:
		var media_library := Services.media_library_controller.media_library
		var md: MediaDescriptor = media_library.media_descriptors[last_selected_media_preview.media_id]
		var path = md.path

		var seek_pos: float = md.preview_seek
		Services.preview_video_stream_player.stream.file = path
		
		Services.preview_video_stream_player.play()
		Services.preview_video_stream_player.stream_position = seek_pos

		var video_texture := Services.preview_video_stream_player.get_video_texture()
		var final_texture: Texture2D
			
		## if the video is a VR video and we try to render it on a flat surface put it through the SphereRenderer
		if md.media_projection.vr_coverage == MediaProjection.VRCoverage.NONE:
			flat_renderer.change_media_projection(md.media_projection)
			flat_renderer.set_srgb_conversion(true)
			flat_renderer.set_video_texture(video_texture)
			final_texture = flat_renderer.get_rendered_texture()
		else:
			sphere_renderer.change_media_projection(md.media_projection)
			sphere_renderer.set_srgb_conversion(true)
			sphere_renderer.set_video_texture(video_texture)
			final_texture = sphere_renderer.get_rendered_texture()
			
			
		last_selected_media_preview.set_media_texture(final_texture)


func _on_media_sort_button_pressed() -> void:
	FSMEventGateway.push("travel_media_sort")
