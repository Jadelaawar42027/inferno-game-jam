extends Node2D

#
#A lot of this is temp at the moment until we have the bosses. Only thing I have is the dialogue
#

@export var lines_talk: Array[DialogLine]
@export var virgil_talk: Array[DialogLine]
@onready var dialog := $UI/DialogMenu
@onready var key_hint: Label = $UI/KeyHint
@onready var dante: AnimatedSprite2D = $Dante
@onready var virgil: AnimatedSprite2D = $Virgil

signal key_pressed
var waiting_for_key := false

const KNIGHT_FRAMES := preload("res://assets/sprites/knight/knight_frames_hd.tres")
const VIRGIL_PORTRAIT := preload("res://assets/sprites/portraits/virgil_portrait.png")

func _ready() -> void:
	dialog.NAME_HERO = "Dante"
	dialog.dialog_start("Greed", lines_talk, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	dialog.dialog_start("Virgil", virgil_talk, false, VIRGIL_PORTRAIT)
	



func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_key and event.is_action_pressed("ui_accept"):
		waiting_for_key = false
		get_viewport().set_input_as_handled()
		key_pressed.emit()
	if event.is_action_pressed("ui_cancel") and not GameState.transitioning: GameState.start_floor(1)
