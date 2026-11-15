extends Control


func _unhandled_input(event):
	if get_tree().current_scene.scene_file_path == GameState.MENU_SCENE: return
	if GameState.transitioning: return
	var dialog := get_tree().get_first_node_in_group("dialog_box")
	if dialog and dialog.visible: return
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused
		get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_pressed() -> void:
	$QuitConfirm.popup_centered()

func _on_quit_confirm_confirmed() -> void:
	visible = false
	GameState.quit_to_menu()
