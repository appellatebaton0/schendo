extends Control

@onready var driver := Global.Driver
@onready var base_color = modulate.srgb_to_linear()

@export var intensity := 1.5

func _process(_delta:float) -> void:
	
	var pulse:float = driver.beat - floor(driver.beat)
	modulate = lerp(modulate, (base_color * lerp(1.0, intensity, 1.0 - pulse)).linear_to_srgb(), 0.4)
