extends Node


var num_players := 32
var bus := "master"

var available : Array[AudioStreamPlayer] = []  # The available players.
var queue : Array[String] = []  # The queue of sounds to play.


func _ready() -> void:
	for i in num_players:
		var p := AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", _on_stream_finished.bind(p))
		p.bus = bus


func _on_stream_finished(stream : AudioStreamPlayer) -> void:
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path : String, min_pitch := 1.0, max_pitch := 1.1, volume := 0.0) -> AudioStreamPlayer:
	queue.append(sound_path)

	var pitch: float = min_pitch + (max_pitch - min_pitch) * randf()

	if available.is_empty():
		push_error("Couldn't play audio. bruh")
		return
	
	var streamer : AudioStreamPlayer = available.pop_back()

	streamer.pitch_scale = pitch
	streamer.volume_db = volume

	streamer.stream = load(queue.pop_front())
	streamer.play()
	

	return streamer