extends Control


func _on_play_button_pressed() -> void:
	print("play is pressed")
	get_tree().change_scene_to_file("res://scenes/levels/scene_1.tscn")


func _on_quit_pressed() -> void:
	print("quit is pressed")
	get_tree().quit()
