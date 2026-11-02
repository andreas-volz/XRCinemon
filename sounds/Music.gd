extends Node

#@export var music_list: Array[AudioStream] = []

var music_list_index = 0
var _stop = false

var music = {
	#"chill_background" : 
#		{"path" : load("res://sounds/assets/792340__zhr__chill-background-music-3.mp3"), "fading" : true}
}

@onready var music_player = $AudioStreamPlayer

func _ready() -> void:
	pass
	#randomize()
	#music_list.shuffle()

func play(music_string: String = ""):
	if not music_string.is_empty():
		music_player.stream = music[music_string]["path"]
	music_player.play()
	

#func list_play():
	#if music_list.size() > 0:
		#stop = false
		#musicPlayer.stream = music_list[music_list_index]
		#musicPlayer.play()
		#music_list_index += 1
		#if music_list_index == music_list.size():
			#music_list_index = 0
	#else:
		#print("Empty Music List")
		
func stop():
	music_player.stop()
	_stop = true

func _on_AudioStreamPlayer_finished() -> void:
	if not stop:
		pass
		# play all?
		#music_player()
