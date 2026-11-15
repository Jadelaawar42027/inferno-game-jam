extends Control


func _on_play_button_pressed() -> void:
	GameState.start_new_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
