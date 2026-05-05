extends Node
## Manages the global things, like the score.

@onready var Driver:MusicDriver = get_tree().get_first_node_in_group("MusicDriver")

## The current song intensity
var intensity:int = 0
