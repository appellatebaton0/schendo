class_name Lane extends Control

@onready var driver:MusicDriver = get_tree().get_first_node_in_group("MusicDriver")

@export var input_name:StringName

func _process(delta: float) -> void:
	if InputMap.has_action(input_name):
		if Input.is_action_just_pressed(input_name):
			print(floor(driver.beat * 4) / 4)
