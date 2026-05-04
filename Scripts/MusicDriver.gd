class_name MusicDriver extends AudioStreamPlayer
## Tracks the current beat, and manages the transitions of tracks.

@export var charter:Array[Chart]

var bpm:float = get_bpm()

var beat := 0.0
var pulse := 0.0

func _ready() -> void:
	
	bpm = get_bpm()

func _process(delta: float) -> void:
	beat = (get_playback_position() +  AudioServer.get_time_since_last_mix()) * bpm * delta
	pulse = beat - floor(beat)

func get_bpm() -> float: 
	
	if stream is AudioStreamSynchronized:
		for i in stream.stream_count:
			var substream:AudioStream = stream.get_sync_stream(i)
			if substream is AudioStream:
				var beats_per = substream.get("bpm")
				if beats_per: return beats_per
	
	return -1.0
