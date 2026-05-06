class_name Song extends Resource
## Manages a set of connected charts, and the score thresholds for buildup.

## For a score rank of [index], use the given state configuration.
@export_flags_2d_physics var state_configurations:Array[int] = [0,0,0,0,0,0,0]

@export var charts:Array[Chart]
