@tool
class_name Chart extends Resource
## Stores information about a track's chart.

@export_tool_button("Load From String") var lfs_button := lfs
@export_multiline() var s:String

## The track this chart is for.
@export var track:AudioStream

## Format the chart with two parts; a list of bools saying whether there's
## A single hit on a beat, and a separate where every bool is an alternating
## Start and end position/

@export var hits:PackedInt64Array
@export var holds:PackedInt64Array

func lfs():
	pass
