class_name MediaLibrary
extends RefCounted

signal scan_finished
signal scan_progress(current_value: int, max_value: int, import_path: String)

enum SortMode {
	TITLE,
	LAST_PLAYED,
	PLAY_COUNT,
	DURATION
}

enum TagFilterMode {
	AND,
	OR
}

var media_library_loader_service := MediaLibraryLoaderService.new()
var media_descriptors: Array[MediaDescriptor] = [] # TODO rename to _array
var preview_cache_dir := "user://preview_cache/"
var max_media_id := 0
var default_tags: Array[String] = []
var preview_thread: Thread = null
var media_extensions: Array[String] = ["mpeg", "mpg", "avi", "ogg", "mp4"]
var seek_preview_position_divider := 5.0

func startup():
	media_library_loader_service.init_service()
	
	scan_finished.connect(_on_scan_finished)

	default_tags = media_library_loader_service.get_default_tags()
		
	media_descriptors.clear()
	
	load_xcm_from_sources()

	#sort_xcm()
	
func load_xcm_from_sources():
	max_media_id = 0
	media_descriptors.clear()
	var source_paths := media_library_loader_service.get_sources()
	for spath in source_paths:
		load_xcm_from_path(spath)
	
func load_xcm_from_path(path: String):
	var xcm_db := JsonVFS.new()
	xcm_db.json_file_extension = "xcm"
	xcm_db.load_all_json(path)
	var xcm_index := xcm_db.get_index()
	
	for xcm_key: String in xcm_index.keys():
		var xcm_value: Dictionary = xcm_index[xcm_key]
		var md := MediaDescriptor.new()
		md.from_json(xcm_value)
		md.id = max_media_id
		md.path = path + xcm_key
		md.preview = preview_cache_dir + str(md.preview_cache) + ".png"
		#print("preview: ", md.preview)
		media_descriptors.append(md)
		max_media_id += 1
		

		
func _scan_thread_function(recreate: bool, guess_tags: bool):
	var ffmpeg_exec_path = "/usr/bin/ffmpeg"
	var ffprobe_exec_path = "/usr/bin/ffprobe"
		
	var md_counter := 0
	for md: MediaDescriptor in media_descriptors:
		var input_video := md.path
		var global_preview_path := ProjectSettings.globalize_path(md.preview)
		if not FileAccess.file_exists(global_preview_path) or recreate:
			print("convert video: ",input_video)
			
			## ffprobe
			#ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4
			var ffprobe_exec_params: Array[String] = [
				"-v", "error",
				"-show_entries",
				"format=duration",
				"-of", "default=noprint_wrappers=1:nokey=1",
				input_video
			]
			
			var ffprobe_output = []
			var ffprobe_exit_code = OS.execute(ffprobe_exec_path, ffprobe_exec_params, ffprobe_output)
			if ffprobe_exit_code != 0:
				push_error("Scan MediaLibrary ffprobe error")
			else:
				var duration_str: String = ffprobe_output.front()
				duration_str = duration_str.trim_suffix("\n")
				var duration: float = float(duration_str)
				md.preview_seek = duration / seek_preview_position_divider
				md.duration = duration
			
			## ffpeg
			var ffmpeg_exec_params: Array[String] = [
				"-y",
				"-ss", str(md.preview_seek),
				"-i", input_video,
				"-frames:v", "1",
				"-update", "1",
				"-vf", "scale=640:-1",
				global_preview_path
			]
			
			var ffmpeg_output = []
			var ffmpeg_exit_code = OS.execute(ffmpeg_exec_path, ffmpeg_exec_params, ffmpeg_output)
			if ffmpeg_exit_code != 0:
				push_error("Scan MediaLibrary ffmpeg error")
		
		md_counter += 1
		scan_progress.emit.call_deferred(md_counter, media_descriptors.size(), input_video)
			
	scan_finished.emit.call_deferred()
		
func scan_media_libray(recreate: bool, guess_tags: bool):
	# start only if no scan is yet running
	if preview_thread == null:
		# make this before starting the thread as this is really fast
		create_xcm_from_sources(recreate, guess_tags)
		load_xcm_from_sources()
		
		preview_thread = Thread.new()
		preview_thread.start(_scan_thread_function.bind(recreate, guess_tags))

func save():
	for media in media_descriptors:
		var file_xcm: String = media.path + ".xcm"
		var json_dict := media.to_json()
		JsonVFS.json_to_file(json_dict, file_xcm)

func create_xcm_from_sources(recreate: bool, guess_tags: bool):
	var source_paths := media_library_loader_service.get_sources()
	for spath in source_paths:
		create_xcm_from_path(spath, recreate, guess_tags)

func create_xcm_from_path(path: String, recreate: bool, guess_tags: bool):
	var available_tags := default_tags
	
	var files := Utils.get_all_files(path, media_extensions)
	for media_file: String in files:
		var xcm_file := media_file + ".xcm"
		if not FileAccess.file_exists(xcm_file) or recreate:
			var md := MediaDescriptor.new()
			var ext := media_file.get_extension()
			md.title = media_file.get_file().rstrip("." + ext).replace("_", " ")
			md.preview_cache = get_cache_hash(media_file)
				
			# some primitive way to guess tags from the file path
			if guess_tags:
				for tag: String in available_tags:
					if media_file.to_lower().contains(tag.to_lower()):
						md.add_tag(tag)
			
			# as last step write the xcm
			var xcm_dict := md.to_json()
			JsonVFS.json_to_file(xcm_dict, xcm_file)




static func sort_by(descriptors: Array[MediaDescriptor], sort_mode: SortMode, descending: bool = false) -> Array[MediaDescriptor]:
	var result := descriptors.duplicate()

	result.sort_custom(func(a: MediaDescriptor, b: MediaDescriptor) -> bool:
		match sort_mode:
			SortMode.TITLE:
				return a.title.nocasecmp_to(b.title) > 0 if descending else a.title.nocasecmp_to(b.title) < 0
			SortMode.LAST_PLAYED:
				return a.last_played > b.last_played if descending else a.last_played < b.last_played
			SortMode.PLAY_COUNT:
				return a.play_count > b.play_count if descending else a.play_count < b.play_count
			SortMode.DURATION:
				return a.duration > b.duration if descending else a.duration < b.duration
		return false
	)

	return result

# TODO: range check and fallback
func get_media_descriptor(id: int) -> MediaDescriptor:
	return media_descriptors[id]
	
## Returns media descriptors matching the specified tags using the selected filter mode (AND/OR)
## An empty tags array returns only media without any tags
func get_media_descriptors_by_tags(tags: Array[String], filter_mode: TagFilterMode = TagFilterMode.AND) -> Array[MediaDescriptor]:
	var filtered_md: Array[MediaDescriptor] = []
	
	if not tags.is_empty():
		for md: MediaDescriptor in media_descriptors:
			var tag_matched := false
			
			for tag in tags:
				if filter_mode == TagFilterMode.OR:
					if md.tags.has(tag):
						tag_matched = true
						break # only add each video once to the filter
				elif filter_mode == TagFilterMode.AND:
					if md.tags.has(tag):
						tag_matched = true
					else:
						tag_matched = false
						break # break at first not fitting 'AND' condition
						
			if tag_matched:
				filtered_md.append(md)
	else:
		# if tags input is emtpy then return the elements without tags
		for md: MediaDescriptor in media_descriptors:
			if md.tags.is_empty():
				filtered_md.append(md)
		
	return filtered_md

func get_cache_hash(file: String) -> int:
	var cache_id := file.get_file() + str(FileAccess.get_modified_time(file)) + str(FileAccess.open(file, FileAccess.READ).get_length())
	var cache_hash := cache_id.hash()
	return cache_hash
		

func get_available_tags() -> Array[String]:
	var complete_tags: Array[String] = []
	complete_tags.append_array(default_tags)
	
	for md: MediaDescriptor in media_descriptors:
		for tag in md.tags:
			if not complete_tags.has(tag):
				complete_tags.append(tag)
				break # only add each tag once to the complete_tags
	
	return complete_tags


func _on_scan_finished():
	preview_thread.wait_to_finish()
	preview_thread = null
	save()
	#startup() # TODO: calling this again doesn't work
