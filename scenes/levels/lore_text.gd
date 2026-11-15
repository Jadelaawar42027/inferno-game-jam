@tool
extends Node2D

@export_multiline var text := "Write here":
	set(value):
		text = value
		if is_node_ready(): label.text = value

@export var font_size := 12:
	set(value):
		font_size = value
		if is_node_ready(): label.add_theme_font_size_override("font_size", value)

@export var color := Color(0.85, 0.9, 1.0)
@export var fade_in := true
@onready var label: Label = $Label
@onready var area: Area2D = $Area2D

func _ready() -> void:
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	if Engine.is_editor_hint(): return
	if not fade_in: return
	label.modulate.a = 0.0
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player: create_tween().tween_property(label, "modulate:a", 1.0, 0.6)
	
func _on_body_exited(body: Node2D) -> void:
	if body is Player: create_tween().tween_property(label, "modulate:a", 0.0, 1.0)
