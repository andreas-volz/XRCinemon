class_name VRFlatControlUI
extends PanelContainer

var rotate_amount := PI / 10.0

func _on_button_up_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.RotateSphereMediaView.new(Vector2(rotate_amount, 0.0)))


func _on_button_left_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.RotateSphereMediaView.new(Vector2(0.0, -rotate_amount)))


func _on_button_right_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.RotateSphereMediaView.new(Vector2(0.0, rotate_amount)))


func _on_button_down_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.RotateSphereMediaView.new(Vector2(-rotate_amount, 0.0)))


func _on_button_middle_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.RotateSphereMediaView.new(Vector2.ZERO, true))
