class_name MediaLibraryLoaderService
extends RefCounted

const PATH := "user://media_library_loader_service.cfg"

var _app_config = AppConfig.new(PATH)

func init_service() -> void:
	_app_config.load()

func replace_sources(paths: Array[String]):
	_app_config.set_value("library", "sources", paths)
	_app_config.save()

func add_source(path: String):
	var paths: Array[String] = get_sources()
	paths.append(path)
	replace_sources(paths)

func get_sources() -> Array[String]:
	return TypeConverters.array_to_array_string(_app_config.get_value("library", "sources", []))

func replace_default_tags(tags: Array[String]):
	_app_config.set_value("library", "default_tags", tags)
	_app_config.save()
	
func add_default_tag(tag: String):
	var tags: Array[String] = get_default_tags()
	tags.append(tag)
	replace_sources(tags)
	
func get_default_tags() -> Array[String]:
	return TypeConverters.array_to_array_string(_app_config.get_value("library", "default_tags", []))
