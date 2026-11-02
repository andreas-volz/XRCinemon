class_name MediaTimelineUI
extends PanelContainer

@onready var current_time_label: Label = %CurrentTimeLabel
@onready var time_slider: HSlider = %TimeSlider
@onready var total_time_label: Label = %TotalTimeLabel

var _slider_update := true

func _ready() -> void:
	if Services.playback_controller:
		var current := Services.playback_controller.get_current_playtime()
		var total := Services.playback_controller.get_total_playtime()
		_on_playback_time_changed(current, total)
		
		Services.playback_controller.playback_time_changed.connect(_on_playback_time_changed)
	
func _on_playback_time_changed(current: float, total: float):
	var current_time := Utils.convert_seconds_to_string(current)
	var total_time := Utils.convert_seconds_to_string(total)
	
	current_time_label.text = current_time
	total_time_label.text = total_time
	
	if _slider_update:
		time_slider.max_value = total
		time_slider.value = current


func _on_time_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		IntentDispatcher.handle_intent(Intent.SeekAbsolutePosition.new(time_slider.value))
	_slider_update = true

func _on_time_slider_drag_started() -> void:
	_slider_update = false
