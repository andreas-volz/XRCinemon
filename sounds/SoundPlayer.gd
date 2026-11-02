extends Node
#Godot4

## overlapping:true means that a sound of that type could overlap itself while playing
## this could sound good or bad depending on the situation and sound
var sounds = {
	#"shot" : 
		#{"path" : load("res://Sounds/Assets/tank-shot.mp3"), "overlapping" : true},
}

@onready var sound_players := get_children()
	
## this function could play as many sounds as we have AudioStreamPlayers in the scene at once
## change 'pitch_scale' a bit to variate sounds played often in a loop
func play(sound_string, pitch_scale: float = 1, volume_db: float = 0, position: Vector3 = Vector3.ZERO):
	for sound_player in sound_players:
		if not sound_player.playing:
			sound_player.pitch_scale = pitch_scale
			sound_player.volume_db = volume_db
			sound_player.stream = sounds[sound_string]["path"]
			sound_player.global_position = position
			sound_player.play()
			return
		else:
			if sound_player.stream == sounds[sound_string]["path"] and sounds[sound_string]["overlapping"] == false:
				break
	#print("too many sound players at once")
	
func stop():
	for child in get_children():
		for sound_player in sound_players:
			if sound_player.playing:
				sound_player.stop()
