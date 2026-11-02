extends PanelContainer

const VIDEO_BUS_NAME := "Video"
var video_bus_idx := AudioServer.get_bus_index(VIDEO_BUS_NAME)
var volume_change := 0.05

@onready var volume_label: Label = %VolumeLabel

func _ready() -> void:
	var current_volume := get_video_volume()
	volume_label.text = str(roundf(current_volume * 100))

func get_video_volume() -> float:
	var current_volume := AudioServer.get_bus_volume_linear(video_bus_idx)
	return current_volume

func set_video_volume(volume: float):
	volume = clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(video_bus_idx, volume)

func _on_play_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.Play.new())

func _on_pause_button_pressed() -> void:
	IntentDispatcher.handle_intent(Intent.Pause.new())

func _on_video_volume_down_pressed() -> void:
	var current_volume := get_video_volume()
	current_volume -= volume_change
	set_video_volume(current_volume)
	volume_label.text = str(roundf(get_video_volume() * 100))

func _on_video_volume_up_pressed() -> void:
	var current_volume := get_video_volume()
	current_volume += volume_change
	set_video_volume(current_volume)
	volume_label.text = str(roundf(get_video_volume() * 100))
	
