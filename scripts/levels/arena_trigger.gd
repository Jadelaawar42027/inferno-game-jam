
extends Area2D

@export var boss: Boss
@export var gates: Array[Node2D]
@export var fight_zoom := Vector2(1.0, 1.0)
@export var pan_time := 0.8

var player: Player
var start_zoom := Vector2.ONE


var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.sin_absorbed.connect(_on_sin_absorbed)
	
func _on_body_entered(body: Node2D) -> void:
	if triggered or not body is Player: return
	triggered = true
	set_deferred("monitoring", false)
	for g in gates: set_gate(g, true)
	body.cutscene_lock = true
	var cam: Camera2D = body.camera
	player = body
	start_zoom = cam.zoom
	var cam_pos := cam.global_position
	cam.top_level = true
	cam.global_position = cam_pos
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	t.tween_property(cam, "global_position", (body.global_position + boss.global_position) / 2.0, pan_time)
	t.tween_property(cam, "zoom", fight_zoom, pan_time)
	await t.finished
	await boss.play_intro(body)
	var back := create_tween().set_trans(Tween.TRANS_SINE)
	back.tween_property(cam, "global_position", body.global_position, 0.4)
	await back.finished
	cam.top_level = false
	cam.position = Vector2.ZERO
	body.cutscene_lock = false
	boss.activate(body)

func set_gate(g: Node2D, closed: bool) -> void:
	var gate_body: StaticBody2D = g.get_node("GateBody")
	gate_body.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT if closed else Node.PROCESS_MODE_DISABLED)
	var spr: AnimatedSprite2D = g.get_node("AnimatedSprite2D")
	if closed:
		spr.play("close")
	else:
		spr.play_backwards("close")
	SFX.play("gate_close" if closed else "gate_open")
	
func _on_sin_absorbed(_a: Ability) -> void:
	if not triggered: return
	for g in gates: set_gate(g, false)
	if not is_instance_valid(player):
		return
	await player.absorb_finished
	create_tween().set_trans(Tween.TRANS_SINE).tween_property(player.camera, "zoom", start_zoom, 0.6)
