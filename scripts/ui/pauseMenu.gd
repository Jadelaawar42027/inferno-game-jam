extends Control


func _unhandled_input(event):
	var dialog_box_check = get_tree().get_first_node_in_group("dialog_box") #Makes sure you cant have the dialog box open
	
	if  event.is_action_pressed("pause"):
		if not dialog_box_check.visible:
			get_tree().paused = true
			get_viewport().set_input_as_handled() #Sets the input as handled
			visible = true
func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_pressed() -> void:
	$QuitConfirm.popup_centered()



func _on_quit_confirm_confirmed() -> void:
	get_tree().paused = false
	get_tree().quit()
