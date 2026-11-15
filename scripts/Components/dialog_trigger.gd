extends Area2D

class_name DialogTrigger
@export var NAME_SPEAKER: String
@export var LINES: Array[DialogLine]
var PLAYER_IN_RANGE := false




#Signals to check if the player is in range
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		PLAYER_IN_RANGE = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		PLAYER_IN_RANGE = false


#Starts dialog if interact key is pressed
func _unhandled_input(event: InputEvent) -> void:
	if PLAYER_IN_RANGE and event.is_action_pressed("interact"):
		var dialog_box = get_tree().get_first_node_in_group("dialog_box")
		if dialog_box and not dialog_box.visible:
			dialog_box.dialog_start(NAME_SPEAKER, LINES)
			get_viewport().set_input_as_handled()
