extends Control


@onready var input_button_scene = preload("res://scenes/ui/input_button.tscn")
var action_list = self
var remapping : bool = false
var action_remap
var button_remap

func _ready():
	_create_action_list()

func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	for action in InputMap.get_actions():
		#Removes Ui_ commands. Has to be set here or it loads in memory
		if not action.begins_with("ui_"):
			var button = input_button_scene.instantiate()
			var action_label = button.find_child("LabelAction")
			var input_label = button.find_child("LabelInput")
			action_label.text = action.replace("_"," ") #replaces _ in acitons
			var events = InputMap.action_get_events(action)
			
			if events.size() > 0:
				
				#Removes the Physical part. Weird check but it works
				if events[0] is InputEventKey:
					input_label.text = events[0].as_text_physical_keycode()
				else:
					input_label.text = events[0].as_text()	
				
			else:
				input_label.text = ""
			action_list.add_child(button)
			button.pressed.connect(_on_input_button_pressed.bind(button, action))
			
func _on_input_button_pressed(button, action):
	if remapping == false:
		remapping = true
		action_remap = action
		button_remap = button
		button.find_child("LabelInput").text = "??"

func _input(event):
	if remapping:
		if event is InputEventKey && event.pressed && not event.echo || (event is InputEventMouseButton && event.pressed):
			InputMap.action_erase_events(action_remap)
			InputMap.action_add_event(action_remap, event)
			_update_action_list(button_remap, event)
			remapping = false
			action_remap = null
			button_remap = null
			get_viewport().set_input_as_handled() #Fixes small bug where slamming click can cause issues 
			
func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
	pass


	
