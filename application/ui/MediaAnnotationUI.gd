class_name MediaAnnotationUI
extends PanelContainer

var media_projection := MediaProjection.new()

@onready var vr_coverage_options: OptionGroup = %VRCoverageOptions
@onready var stereo_format_options: OptionGroup = %StereoFormatOptions
@onready var projection_options: OptionGroup = %ProjectionOptions


func _ready() -> void:
	if Services.media_library_controller:
		if Services.media_library_controller.selected_media_descriptor:
			media_projection = Services.media_library_controller.selected_media_descriptor.media_projection
		else:
			media_projection = MediaProjection.new()
	
	match (media_projection.projection_format):
		MediaProjection.ProjectionFormat.STANDARD_UV:
			projection_options.select_buttons(["StandardUVProjButton"])
		MediaProjection.ProjectionFormat.EQUIANGULAR:
			projection_options.select_buttons(["EACProjButton"])
			
	match (media_projection.stereo_format):
		MediaProjection.StereoFormat.MONO:
			stereo_format_options.select_buttons(["MonoButton"])
		MediaProjection.StereoFormat.SIDE_BY_SIDE:
			stereo_format_options.select_buttons(["SideBySideButton"])
		MediaProjection.StereoFormat.OVER_UNDER:
			stereo_format_options.select_buttons(["OverUnderButton"])

	match (media_projection.vr_coverage):
		MediaProjection.VRCoverage.NONE:
			vr_coverage_options.select_buttons(["NoVRButton"])
		MediaProjection.VRCoverage.HALF_SPHERE:
			vr_coverage_options.select_buttons(["VR180Button"])
		MediaProjection.VRCoverage.FULL_SPHERE:
			vr_coverage_options.select_buttons(["VR360Button"])

func change_media_projection_intent():
	IntentDispatcher.handle_intent(Intent.ChangeMediaProjection.new(media_projection))
	Services.media_library_controller.media_library.save()
	
func _on_close_button_pressed() -> void:
	FSMEventGateway.push("travel_video_display")

func _on_vr_coverage_options_selection_changed(button: OptionItemButton) -> void:
	match button.option_id:
		"NoVRButton":
			media_projection.vr_coverage = MediaProjection.VRCoverage.NONE
		"VR360Button":
			media_projection.vr_coverage = MediaProjection.VRCoverage.FULL_SPHERE
		"VR180Button":
			media_projection.vr_coverage = MediaProjection.VRCoverage.HALF_SPHERE
	change_media_projection_intent()

func _on_stereo_format_options_selection_changed(button: OptionItemButton) -> void:
	match button.option_id:
		"MonoButton":
			media_projection.stereo_format = MediaProjection.StereoFormat.MONO
		"SideBySideButton":
			media_projection.stereo_format = MediaProjection.StereoFormat.SIDE_BY_SIDE
		"OverUnderButton":
			media_projection.stereo_format = MediaProjection.StereoFormat.OVER_UNDER
	change_media_projection_intent()

func _on_projection_options_selection_changed(button: OptionItemButton) -> void:
	match button.option_id:
		"StandardUVProjButton":
			media_projection.projection_format = MediaProjection.ProjectionFormat.STANDARD_UV
		"EACProjButton":
			media_projection.projection_format = MediaProjection.ProjectionFormat.EQUIANGULAR
	change_media_projection_intent()
