extends Node2D

func _ready() -> void:
	MusicManager.play("final_poem", 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): GameState.quit_to_menu()
