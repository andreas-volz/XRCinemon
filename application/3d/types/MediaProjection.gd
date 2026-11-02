class_name MediaProjection
extends RefCounted

enum StereoFormat {
	MONO = 0,
	SIDE_BY_SIDE = 1,
	OVER_UNDER = 2
}

enum ProjectionFormat {
	STANDARD_UV = 0,
	EQUIANGULAR = 1
}

enum VRCoverage {
	NONE = 0,
	HALF_SPHERE = 1,
	FULL_SPHERE = 2
}

var stereo_format: StereoFormat = StereoFormat.MONO
var projection_format: ProjectionFormat = ProjectionFormat.STANDARD_UV
var vr_coverage: VRCoverage = VRCoverage.NONE

const _STEREO_FORMAT_MAP := {
	StereoFormat.MONO: "mono",
	StereoFormat.SIDE_BY_SIDE: "side-by-side",
	StereoFormat.OVER_UNDER: "over-under"
}
static var _STEREO_FORMAT_REVERSE_MAP := Utils.build_reverse_map(_STEREO_FORMAT_MAP)

const _PROJECTION_FORMAT_MAP := {
	ProjectionFormat.STANDARD_UV: "standard-uv",
	ProjectionFormat.EQUIANGULAR: "equiangular"
}
static var _PROJECTION_FORMAT_MAP_REVERSE_MAP := Utils.build_reverse_map(_PROJECTION_FORMAT_MAP)

const _VR_COVERAGE_MAP := {
	VRCoverage.NONE: "none",
	VRCoverage.HALF_SPHERE: "half-sphere",
	VRCoverage.FULL_SPHERE: "full-sphere"
}
static var _VR_COVERAGE_REVERSE_MAP := Utils.build_reverse_map(_VR_COVERAGE_MAP)

func to_json() -> Dictionary:
	var dict: Dictionary = {}
	
	dict["stereo_format"] = _STEREO_FORMAT_MAP.get(stereo_format, "")
	dict["projection_format"] = _PROJECTION_FORMAT_MAP.get(projection_format, "")
	dict["vr_coverage"] = _VR_COVERAGE_MAP.get(vr_coverage, "")

	return dict

func from_json(dict: Dictionary) -> bool:
	var result: bool = true
	var tmp_value
	
	tmp_value = dict.get("stereo_format")
	if tmp_value is String:
		stereo_format = _STEREO_FORMAT_REVERSE_MAP.get(tmp_value, stereo_format)
		
	tmp_value = dict.get("projection_format")
	if tmp_value is String:
		projection_format = _PROJECTION_FORMAT_MAP_REVERSE_MAP.get(tmp_value, projection_format)
		
	tmp_value = dict.get("vr_coverage")
	if tmp_value is String:
		vr_coverage = _VR_COVERAGE_REVERSE_MAP.get(tmp_value, vr_coverage)
		
	return result
