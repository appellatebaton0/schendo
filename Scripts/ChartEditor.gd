@tool class_name ChartEditor extends AudioStreamPlayer2D
## Allows for editing a chart. A simple tool.

@export_tool_button("Save To Chart", "Save") var stc := save_chart

#@export var 
@export var chart:Chart

@export var hit_parent:Node2D
@export var has_hit:Dictionary[Node, bool]
@export var hold_parent:Node2D

@export var hit_sfx:AudioStreamPlayer2D
@export var hold_sfx:AudioStreamPlayer2D

## The position of the beat.
@export var beat := 0.0

var was_playing := false
func _process(delta: float) -> void:
	queue_redraw()
	
	if not was_playing and playing:
		play(beat / (stream.bpm / 60))
	
	if playing:
		beat = ((get_playback_position() + AudioServer.get_time_since_last_mix()) * stream.bpm / 60)
		
		for node in hit_parent.get_children() + hold_parent.get_children():
			if not has_hit.has(node) or beat < (node.position.x / 8) - delta: has_hit[node] = false
		
			if beat >= (node.position.x / 8) - delta and not has_hit[node]:
				hit_sfx.play()
				
				has_hit[node] = true
		
	was_playing = playing

func _draw():
	
	var width:float = stream.beat_count * 8
	draw_line(Vector2(-2, 10), Vector2(-2, -2), Color.RED, 2)
	draw_line(Vector2(-3,-2), Vector2(width, -2), Color.RED, 2)
	draw_line(Vector2(-3,10), Vector2(width, 10), Color.RED, 2)
	draw_line(Vector2(width, 11), Vector2(width, -3), Color.RED, 2)
	
	for hit_node in hit_parent.get_children(): if hit_node is Node2D:
		draw_circle(hit_node.global_position - position, 0.7, Color.AQUA if beat < hit_node.position.x / 8 else Color.ROYAL_BLUE)
		
		if not has_hit.has(hit_node) or beat < hit_node.position.x / 8: has_hit[hit_node] = false
		
	
	var partner:Node2D = null
	for hold_node in hold_parent.get_children(): if hold_node is Node2D:
		if not partner:
			partner = hold_node
		else:
			draw_line(partner.global_position - position, hold_node.global_position - position, Color.GREEN, 0.5)
			partner = null
		draw_circle(hold_node.global_position - position, 0.7, Color.GREEN)
		
		
	
	draw_line(Vector2(beat * 8, -4), Vector2(beat * 8, 12), Color.WHITE, 0.4)

func save_chart():
	
	## The number of half-beats (each half-beat is stored.
	var length:int = stream.beat_count * 2
	## The number of 64-bit-ints this track will need.
	var ints:int = ceil(length / 64)
	
	var new_hits :PackedInt64Array
	var new_holds:PackedInt64Array
	
	for i in range(ints):
		new_hits .append(0)
		new_holds.append(0)
	
	## Save the points' locations in their corresponding bits.
	
	# For hits
	for node in hit_parent.get_children(): if node is Node2D:
		var i:int = int(node.position.x / 4)
		
		## The int to store this bit in
		var store_int := i >> 6
		## The index to store this bit in
		var store_index := int(pow(2, (i - (store_int << 6) -1)))
		
		new_hits.set(store_int, new_hits.get(store_int) | store_index)
	
	# For holds
	for node in hold_parent.get_children(): if node is Node2D:
		var i:int = int(node.position.x / 4)
		
		## The int to store this bit in
		var store_int := i >> 6
		## The index to store this bit in
		var store_index := int(pow(2, (i - (store_int << 6) -1)))
		
		new_holds.set(store_int, new_holds.get(store_int) | store_index)
	
	
	var unre := EditorInterface.get_editor_undo_redo()
	
	unre.create_action("Save Chart")
	
	unre.add_do_property(chart, "hits",  new_hits)
	unre.add_do_property(chart, "holds", new_holds)
	
	unre.add_undo_property(chart, "hits",  chart.hits)
	unre.add_undo_property(chart, "holds", chart.holds)
	
	unre.commit_action()
