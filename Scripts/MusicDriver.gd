class_name MusicDriver extends AudioStreamPlayer
## Tracks the beat, and manages the transitions of tracks.

@export var charter:Array[Chart]

var bpm:float

var beat_delta:float
var beat := 0.0:
	set(to):
		beat_delta = abs(to - beat)
		beat = to

## The currently active tracks.
@export_flags_2d_render var state:int: set = set_state
## The tracks that are in the middle of transitioning.
var untransitioned:int = 0

## Used to buffer the state change until the start of a beat.
var transition_start_beat := -1
var state_buffer:int

## How many beats it takes to fade in or out a track.
@export var transition_beats := 8

func _ready() -> void:
	
	## Create the stream.
	var new_stream := AudioStreamSynchronized.new()
	
	new_stream.set_stream_count(len(Global.song.charts))
	
	for i in range(len(Global.song.charts)):
		new_stream.set_sync_stream(i, Global.song.charts[i].track)
		new_stream.set_sync_stream_volume(i, linear_to_db(0))
		
		if not bpm:
			var beats_per = Global.song.charts[i].track.get("bpm")
			if beats_per:
				bpm = beats_per
	
	set_stream(new_stream)
	
	play()

func _process(_delta: float) -> void:
	
	beat = (get_playback_position() +  AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()) * bpm / 60
	
	## If there's a waiting buffer, attempt to clear it.
	if state_buffer != state:
		state = state_buffer
	print(state, ' / ',state_buffer)
	
	## Manage the transition of track volumes.
	if stream is AudioStreamSynchronized:
		var index := 1
		
		for i in range(31): 
			if untransitioned & index:
				
				var new_value:float = move_toward(db_to_linear(stream.get_sync_stream_volume(i)), float((state & index) >> i), beat_delta / transition_beats)
				
				stream.set_sync_stream_volume(i, linear_to_db(new_value))
				
				# If the value is what it's supposed to be, erase
				# This index from the untransitioned list.
				if new_value == (state & index) >> (i):
					untransitioned ^= index
			
			index *= 2

func set_state(to:int): 
	if floor(beat) > transition_start_beat and transition_start_beat >= 0:
		## Note which bits have changed, since they'll need to be transitioned.
		## Keep on any that still aren't done.
		untransitioned = untransitioned | (state ^ to)
		
		## Update the state
		state = to
		
		transition_start_beat = -1
	else:
		if transition_start_beat == -1:
			transition_start_beat = ceil(beat)
		state_buffer = to
	
	
