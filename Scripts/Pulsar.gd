extends Control

@onready var driver:MusicDriver = get_tree().get_first_node_in_group("MusicDriver")
@onready var base_color = modulate.srgb_to_linear()

@export var intensity := 1.5

func _process(_delta:float) -> void:
	
	# Next, multiply it by your intensity
	modulate = lerp(modulate, (base_color * lerp(1.0, intensity, 1.0 - driver.pulse)).linear_to_srgb(), 0.4)
