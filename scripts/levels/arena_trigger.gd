
extends Area2D

@export var boss: Boss
@export var gates: Array[Node2D]

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.sin_absorbed.connect(_on_sin_absorbed)
	
func _on_body_entered(body: Node2D) -> void:
	if triggered or not body is Player: return
	triggered = true
	set_deferred("monitoring", false)
	for g in gates: set_gate(g, true)
	boss.activate(body)
	
func set_gate(g: Node2D, closed: bool) -> void:
	var gate_body: StaticBody2D = g.get_node("GateBody")
	gate_body.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT if closed else Node.PROCESS_MODE_DISABLED)
	var spr: AnimatedSprite2D = g.get_node("AnimatedSprite2D")
	if closed:
		spr.play("close")
	else:
		spr.play_backwards("close")
	
func _on_sin_absorbed(_a: Ability) -> void:
	if not triggered: return
	for g in gates: set_gate(g, false)
