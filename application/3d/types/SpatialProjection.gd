class_name SpatialProjection
extends RefCounted

enum Type {
	FLAT,
	SPHERE,
}

var type: Type = Type.FLAT

func _init(type_param: Type = Type.FLAT) -> void:
	type = type_param
