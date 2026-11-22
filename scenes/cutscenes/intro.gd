extends Node2D

@export var lines_wake: Array[DialogLine]
@export var lines_talk: Array[DialogLine]
@export var lines_spell: Array[DialogLine]
@onready var dialog := $UI/DialogMenu
@onready var key_hint: Label = $UI/KeyHint
@onready var dante: AnimatedSprite2D = $Dante
@onready var virgil: AnimatedSprite2D = $Virgil
@onready var cutscene_frames := dante.sprite_frames
@export var lines_after: Array[DialogLine]
@onready var circle_glow: Sprite2D = $CircleGlow
@onready var circle_light: PointLight2D = $Lights/CircleLight
@onready var staff_glow: CPUParticles2D = $StaffGlow

signal key_pressed
var waiting_for_key := false

const KNIGHT_FRAMES := preload("res://assets/sprites/knight/knight_frames_hd.tres")
const VIRGIL_PORTRAIT := preload("res://assets/sprites/portraits/virgil_portrait.png")

func _ready() -> void:
	MusicManager.play("awakening")
	var pulse := create_tween().set_loops()
	pulse.tween_property(circle_glow, "modulate:a", 0.3, 2.2).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(circle_light, "energy", 0.55, 2.2).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(circle_glow, "modulate:a", 0.6, 2.2).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(circle_light, "energy", 0.75, 2.2).set_trans(Tween.TRANS_SINE)
	dialog.NAME_HERO = "Dante"
	dante.play("sleep")
	virgil.play("idle")
	await get_tree().create_timer(2.0).timeout
	dante.play("wake")
	await dante.animation_finished
	virgil.play("talk")
	dialog.dialog_start("Virgil", lines_wake, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	virgil.play("idle")
	dante.play("get_up")
	await dante.animation_finished
	dante.sprite_frames = KNIGHT_FRAMES
	dante.play("idle")
	virgil.play("talk")
	dialog.dialog_start("Virgil", lines_talk, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	virgil.play("cast")
	await virgil.animation_finished
	virgil.play("cast_hold")
	staff_glow.amount = 40
	dialog.dialog_start("Virgil", lines_spell, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	key_hint.text = "Press ENTER — Vinculum Aeternum"
	key_hint.visible = true
	waiting_for_key = true
	await key_pressed
	key_hint.visible = false
	dante.sprite_frames = cutscene_frames
	dante.play("spell_learn")
	await dante.animation_finished
	dante.sprite_frames = KNIGHT_FRAMES
	dante.play("idle")
	virgil.play("talk")
	staff_glow.amount = 14
	dialog.dialog_start("Virgil", lines_after, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	virgil.play("idle")
	GameState.start_floor(1)

func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_key and event.is_action_pressed("ui_accept"):
		waiting_for_key = false
		get_viewport().set_input_as_handled()
		key_pressed.emit()
	if event.is_action_pressed("ui_cancel") and not GameState.transitioning: GameState.start_floor(1)
