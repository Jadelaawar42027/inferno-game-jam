extends Control

@export var NAME_HERO = "HERO"
@export var NAME_TARGET = "OTHER"
var LINES_ARRAY : Array[DialogLine] = [] #Sets the array to the dialog line
var LINES_INDEX = 0
var paused_by_me := false

signal dialog_finished

#onready vars
@onready var HERO_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Hero
@onready var TARGET_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Other
@onready var TEXT_CONTAINER = $PanelContainer/MarginContainer/VBoxContainer/Text


func _ready() -> void:
	visible = false

func dialog_start(target_name: String, lines: Array[DialogLine], pause_game := true):
	if lines.is_empty(): return
	NAME_TARGET = target_name
	LINES_ARRAY = lines
	LINES_INDEX = 0
	show_line()
	visible = true
	paused_by_me = pause_game
	if pause_game: get_tree().paused = true

func show_line():
	var line = LINES_ARRAY[LINES_INDEX]
	
	if line == null:
		push_error("DialogTrigger Cannot have empty element at index " + str(LINES_INDEX))
	else:
		TEXT_CONTAINER.text = line.TEXT
		if line.SPEAKER == DialogLine.STATE_SPEAKER.HERO:
			HERO_CONTAINER.text = NAME_HERO
			TARGET_CONTAINER.text = ""
		elif line.SPEAKER == DialogLine.STATE_SPEAKER.OTHER:
			HERO_CONTAINER.text = ""
			TARGET_CONTAINER.text = NAME_TARGET
		if line.VOICE != "": VoiceManager.play_line(line.VOICE, "Master")

func next_line():
	LINES_INDEX += 1
	if LINES_INDEX < LINES_ARRAY.size():
		show_line()
	else:
		visible = false
		if paused_by_me: get_tree().paused = false
		dialog_finished.emit()

#Interact key is set to E at the moment
func _unhandled_input(event):
	if visible and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
		next_line()
		get_viewport().set_input_as_handled()
		
