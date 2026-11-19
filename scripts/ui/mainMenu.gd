extends Control


func _on_play_button_pressed() -> void:
	SFX.play("ui_select")
	GameState.start_new_game()


func _on_quit_pressed() -> void:
	SFX.play("ui_select")
	get_tree().quit()


#Returns to main menu
func _on_returnto_main_pressed() -> void:
	SFX.play("ui_select")
	%SettingsPanelContainer.visible = false
	%CenterContainer.visible = true


#Opens the setting page
func _on_settings_pressed() -> void:
	SFX.play("ui_select")
	%SettingsPanelContainer.visible = true
	%CenterContainer.visible = false

#

#Opens the keybind menu
func _on_keybinds_pressed() -> void:
	SFX.play("ui_select")
	%SettingsPanelContainer.visible = false
	%KeybindsPanelContainer.visible = true
	
#Closes the keybind menu back to the settings menu
func _on_return_to_settings_pressed() -> void:
	%SettingsPanelContainer.visible = true
	%KeybindsPanelContainer.visible = false

func _set_bus(bus: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(value))
