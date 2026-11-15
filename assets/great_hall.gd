extends Node2D
# Parallax driven by this script instead of Parallax2D, so the layers can never run out at either end.
# Each layer image is placed so it slides at (scale x camera speed): 1.0 = stays in the world, <1 = further away, >1 = in front.
const SCALES := {"Far": 0.45, "Mid": 0.7, "Stage": 1.0, "Front": 1.0}
@export var speed := 300.0
@export var hall_width := 2176.0   # width of one layer image in pixels
@onready var cam: Camera2D = $Camera2D

func _process(delta: float) -> void:
	var half := get_viewport_rect().size.x * 0.5
	cam.position.x = clamp(cam.position.x + Input.get_axis("ui_left", "ui_right") * speed * delta, half, hall_width - half)
	var left := cam.position.x - half
	for layer_name in SCALES:
		get_node(layer_name).position.x = left * (1.0 - SCALES[layer_name])
