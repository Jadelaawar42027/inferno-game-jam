extends Control

@export var NAME_HERO = "HERO"
@export var NAME_TARGET = "OTHER"
var LINES_ARRAY : Array[DialogLine] = [] #Sets the array to the dialog line
var LINES_INDEX = 0

signal dialog_finished

#onready vars
@onready var HERO_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Hero
@onready var TARGET_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Other
@onready var TEXT_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/Text


func dialog_start(target_name: String, lines: Array[DialogLine]):
	NAME_TARGET = target_name
	LINES_ARRAY = lines
	LINES_INDEX = 0
	show_line()
	
	#Sets ui to visible and pauses the game
	visible = true
	get_tree().paused = true

func show_line():
	var line = LINES_ARRAY[LINES_INDEX]
	TEXT_CONTAINER.text = line.TEXT
	
	if line.SPEAKER == DialogLine.STATE_SPEAKER.HERO:
		HERO_CONTAINER.text = NAME_HERO
		TARGET_CONTAINER.text = ""
	elif line.SPEAKER == DialogLine.STATE_SPEAKER.OTHER:
		HERO_CONTAINER.text = ""
		TARGET_CONTAINER.text = NAME_TARGET

func next_line():
	LINES_INDEX += 1
	if LINES_INDEX < LINES_ARRAY.size():
		show_line()
	else:
		visible = false
		get_tree().paused = false
		dialog_finished.emit()

#Interact key is set to E at the moment
func _unhandled_input(event):
	if visible and event.is_action_pressed("interact"):
		next_line()
		get_viewport().set_input_as_handled()
		
