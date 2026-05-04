class_name MusicDriver extends AudioStreamPlayer
## Tracks the current beat, and manages the transitions of tracks.

@export var charter:Array[Chart]

var bpm:float

var beat := 0.0
var pulse := 0.0

## The currently active tracks.
@export_flags_2d_render var state:int : set = set_state
## The tracks that are in the middle of transitioning.
var untransitioned:int = 0

## How many beats it takes to fade in or out a track.
@export var transition_beats := 8

func _ready() -> void:
	
	## Create the stream.
	var new_stream := AudioStreamSynchronized.new()
	
	new_stream.set_stream_count(len(charter))
	
	for i in range(len(charter)):
		new_stream.set_sync_stream(i, charter[i].track)
		new_stream.set_sync_stream_volume(i, linear_to_db(0))
		
		if not bpm:
			var beats_per = charter[i].track.get("bpm")
			if beats_per:
				bpm = beats_per
	
	set_stream(new_stream)
	
	play()

func _process(delta: float) -> void:
	beat = (get_playback_position() +  AudioServer.get_time_since_last_mix()) * bpm * delta
	pulse = beat - floor(beat)
	
	var index := 1
	for i in range(31): 
		if untransitioned & index:
			print(i)
		index *= 2

func set_state(to:int):
	
	## Note which bits have changed, since they'll need to be transitioned.
	untransitioned = state ^ to
	
	print(state, " -> ", to, " = ", untransitioned)
	
	state = to
