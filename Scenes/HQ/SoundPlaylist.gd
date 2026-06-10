class_name SoundPlaylist extends AudioStreamPlayer3D

@export var array : Array[AudioStream]
@export var mode : Modes


enum Modes{
	Random,
	Next
}

var cur_index := 0

func _ready() -> void:
	finished.connect(new_music)
	new_music()

func new_music() -> void:
	var next_stream : AudioStream

	match mode:
		Modes.Random:
			var new_cur_index := randi_range(0, array.size() - 1)
			if new_cur_index >= cur_index:
				new_cur_index += 1
			
			cur_index = new_cur_index
		Modes.Next:
			cur_index += 1
	
	cur_index = cur_index % array.size()
	next_stream = array[cur_index]

	stream = next_stream

	play()