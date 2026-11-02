class_name VideoUI
extends CenterContainer

const CINEMA_SPACE = preload("uid://cuc2sbx774i8w")
const SCIFI_BRIDGE_SPACE = preload("uid://b1ycpwxrs2l8i")
const EXPERIMENTAL_SPACE = preload("uid://6psdq5cfxmdw")

func _on_cinema_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.SelectSpace.new(CINEMA_SPACE))
	FSMEventGateway.push("travel_video_player")

func _on_spaceship_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.SelectSpace.new(SCIFI_BRIDGE_SPACE))
	FSMEventGateway.push("travel_video_player")

func _on_flat_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.ChangeSpatialProjection.new(SpatialProjection.new(SpatialProjection.Type.FLAT)))
	FSMEventGateway.push("travel_video_player")

func _on_sphere_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.ChangeSpatialProjection.new(SpatialProjection.new(SpatialProjection.Type.SPHERE)))
	FSMEventGateway.push("travel_video_player")

func _on_return_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.Stop.new())
	FSMEventGateway.push("travel_media_browser")
	Services.media_library_controller.media_library.save()

func _on_preview_button_pressed() -> void:
	FSMEventGateway.push("travel_media_import")
	

func _on_annotation_editor_button_pressed() -> void:
	FSMEventGateway.push("travel_annotation_editor")


func _on_calibrate_height_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.CalibrateSpaceCharacterHeight.new())


func _on_experimental_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.SelectSpace.new(EXPERIMENTAL_SPACE))
