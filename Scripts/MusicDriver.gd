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
## The beat the transition starts from.
var transition_start_beat:int = 0

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

func _process(_delta: float) -> void:
	beat = (get_playback_position() +  AudioServer.get_time_since_last_mix()) * bpm / 60
	pulse = beat - floor(beat)
	
	if stream is AudioStreamSynchronized:
		var index := 1
		
		# How close to the end of the transition (0.0 - 1.0) we are.
		var transition_time := (beat - transition_start_beat) / transition_beats
		
		for i in range(31): 
			if untransitioned & index:
				
				var new_value:float = clamp(transition_time if state & index else 1 - transition_time, 0., 1.)
				
				stream.set_sync_stream_volume(i, linear_to_db(new_value))
				
				# If the value is what it's supposed to be, erase
				# This index from the untransitioned list.
				if new_value == (state & index) >> (i):
					untransitioned ^= index
			
			index *= 2
	
	## Every half beat.
	if floor(beat * 2) / 2 != last_beat:
		last_beat = floor(beat * 2) / 2
		print(last_beat)

var last_beat := 0.0
var string := ""

func set_state(to:int):
	
	## Note which bits have changed, since they'll need to be transitioned.
	untransitioned = state ^ to
	
	transition_start_beat = ceil(beat)
	
	state = to
