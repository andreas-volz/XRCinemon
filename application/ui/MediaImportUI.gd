extends PanelContainer

@onready var recreate_button: CheckButton = $CenterContainer/VBoxContainer/RecreateButton
@onready var guess_tags_button: CheckButton = $CenterContainer/VBoxContainer/GuessTagsButton
@onready var import_progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ImportProgressBar
@onready var import_path_label: Label = $CenterContainer/VBoxContainer/ImportPathLabel
@onready var flat_renderer: FlatRenderer = $FlatRenderer


func _ready() -> void:
	if Services.media_library_controller:
		Services.media_library_controller.media_library.scan_progress.connect(_on_scan_progress)

func scan_media_library(recreate: bool, guess_tags: bool):
	Services.media_library_controller.media_library.create_xcm_from_sources(recreate, guess_tags)
	
	for md in Services.media_library_controller.media_library.media_descriptors:
		var global_preview_path := ProjectSettings.globalize_path(md.preview)
		if not FileAccess.file_exists(global_preview_path) or recreate:
			create_preview_image(md.path, md.preview)
			print("md.path:", md.path)
			print("md.preview:", md.preview)
	
func create_preview_image(media_path: String, preview_path: String):
	Services.preview_video_stream_player.stream.file = media_path
	
	var stream_length := Services.preview_video_stream_player.get_stream_length()
	print("get_stream_length(): ", stream_length)
	
	Services.preview_video_stream_player.play()
	Services.preview_video_stream_player.stream_position = stream_length / 5.0
	
	await wait_on_rendered_frame()
	
	var video_texture := Services.preview_video_stream_player.get_video_texture()
	
	var media_projection := MediaProjection.new()
	flat_renderer.change_media_projection(media_projection)
	
	var rendered_preview_image = await flat_renderer.render_preview(video_texture)
	rendered_preview_image.save_png(preview_path)
	
## FIXME
## this function is a workaround to "wait" until the ffmpeg addon has rendered the forst frame
## for sure this is complete rubish and works only by chance on the system or video load time
## a real solution might be to add a first_frame_loaded signal or so to FFmpegVideoStream
func wait_on_rendered_frame():
	for i in 50:
		await RenderingServer.frame_post_draw

func _on_import_button_pressed() -> void:
	var scan_media_library_intent := Intent.ScanMediaLibrary.new()
	scan_media_library_intent.recreate = recreate_button.button_pressed
	scan_media_library_intent.guess_tags = guess_tags_button.button_pressed
	IntentDispatcher.handle_intent(scan_media_library_intent)
	#scan_media_library(recreate_button.button_pressed, guess_tags_button.button_pressed)


func _on_scan_progress(current_value: int, max_value: int, import_path: String):
	import_progress_bar.max_value = max_value
	import_progress_bar.value = current_value
	
	# show a part of the import path while importing
	var import_file := import_path.get_file()
	#var import_ext = import_file.get_extension()
	var import_label: String = import_file.left(20).rstrip(" ") + "..."
	import_path_label.text = import_label
