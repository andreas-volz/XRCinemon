class_name MediaDescriptor
extends RefCounted

#######################
## persistent data 
#######################

var title: String
var media_projection := MediaProjection.new()
var preview_cache: int
var preview_seek: float
var last_played: float
var play_count: int
var tags : Array[String] = []
var duration: float

#######################
## runtime data
#######################

var id: int
var path: String
var preview: String

#######################
## functions
#######################

func add_tag(tag: String):
	if not tags.has(tag):
		tags.append(tag)
		
func remove_tag(tag: String):
	tags.erase(tag)

func to_json() -> Dictionary:
	var dict: Dictionary = {}
	
	dict["title"] = title
	dict["media_projection"] = media_projection.to_json()
	dict["preview_cache"] = preview_cache
	dict["preview_seek"] = preview_seek
	dict["last_played"] = last_played
	dict["play_count"] = play_count
	dict["tags"] = tags
	dict["duration"] = duration
	
	return dict
	
func from_json(dict: Dictionary) -> bool:
	var result: bool = true
	var tmp_value
	
	tmp_value = dict.get("title")
	if tmp_value is String:
		title = tmp_value
	
	tmp_value = dict.get("tags")
	if tmp_value is Array:
		tags = TypeConverters.array_to_array_string(tmp_value)
	
	tmp_value = dict.get("media_projection")
	if tmp_value is Dictionary:
		media_projection.from_json(tmp_value)
		
	tmp_value = dict.get("preview_cache")
	if tmp_value is int or tmp_value is float:
		preview_cache = tmp_value

	tmp_value = dict.get("preview_seek")
	if tmp_value is int or tmp_value is float:
		preview_seek = tmp_value
		
	tmp_value = dict.get("last_played")
	if tmp_value is int or tmp_value is float:
		last_played = tmp_value
		
	tmp_value = dict.get("play_count")
	if tmp_value is int or tmp_value is float:
		play_count = tmp_value
	
	tmp_value = dict.get("duration")
	if tmp_value is int or tmp_value is float:
		duration = tmp_value
	
	return result
