extends Node
## Manages the global things, like the score.

@onready var Driver:MusicDriver = get_tree().get_first_node_in_group("MusicDriver")

@onready var song := preload("res://Assets/Songs/TheGlass.tres")

## The current song intensity
var intensity:int = 0
