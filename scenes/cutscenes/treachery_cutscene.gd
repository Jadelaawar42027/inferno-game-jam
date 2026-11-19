extends Node2D

const VIRGIL_PORTRAIT := preload("res://assets/sprites/portraits/virgil_portrait.png")
const SATAN_PORTRAIT := preload("res://assets/sprites/portraits/satan_portrait.png")

@export var lines_virgil: Array[DialogLine]
@export var lines_satan: Array[DialogLine]
@onready var player: Player = $"../Player"
@onready var satan: Boss = $"../Satan"
@onready var virgil: AnimatedSprite2D = $Virgil
@onready var trigger: Area2D = $Trigger
@onready var gates: Array[Node] = $"../Gates".get_children()

var cam: Camera2D
var triggered := false

const FX := preload("res://scenes/fx/boss_fx.tscn")

@export var lines_quake: Array[DialogLine]
@export var lines_goodbye: Array[DialogLine]

var quaking := false


func _ready() -> void:
	trigger.body_entered.connect(_on_trigger_body_entered)
	satan.boss_defeated.connect(_on_satan_defeated)
	if GameState.satan_intro_seen: virgil.hide()

func _on_trigger_body_entered(body: Node2D) -> void:
	if triggered or not body is Player: return
	triggered = true
	trigger.set_deferred("monitoring", false)
	player.cutscene_lock = true
	for g in gates: set_gate(g)
	grab_camera()
	if GameState.satan_intro_seen: await play_short()
	else: await play_full()
	GameState.satan_intro_seen = true
	await release_camera()
	player.cutscene_lock = false
	satan.intro_done = true 
	satan.activate(player)

func play_full() -> void:
	var dialog = get_tree().get_first_node_in_group("dialog_box")
	await pan_to($CamDuel.global_position)
	virgil.play("talk")
	dialog.dialog_start("Virgil", lines_virgil, false, VIRGIL_PORTRAIT)
	await dialog.dialog_finished
	await pan_to($CamFace.global_position, 0.6)
	virgil.play("dissolve")
	var drift := create_tween().set_parallel()
	drift.tween_property(virgil, "global_position", satan.global_position + Vector2(0, -60), 1.2)
	drift.tween_property(virgil, "modulate:a", 0.0, 1.2)
	await drift.finished
	virgil.hide()
	SFX.play("ice_crack")
	player.shake(3.0)
	await satan.play_and_wait("cracking")
	await satan.play_and_wait("rise")
	await satan.play_and_wait("roar")
	satan.sprite.play("idle")
	await pan_to($CamDuel.global_position, 0.5)
	dialog.dialog_start("Satan", lines_satan, false, SATAN_PORTRAIT)
	await dialog.dialog_finished

func play_short() -> void:
	await pan_to($CamDuel.global_position, 0.5)
	await satan.play_and_wait("rise")
	await satan.play_and_wait("roar")

func grab_camera() -> void:
	cam = player.camera
	var p := cam.global_position
	cam.top_level = true
	cam.global_position = p

func pan_to(pos: Vector2, time := 0.8) -> void:
	await create_tween().set_trans(Tween.TRANS_SINE).tween_property(cam, "global_position", pos, time).finished

func release_camera() -> void:
	await pan_to(player.global_position, 0.5)
	cam.top_level = false
	cam.position = Vector2.ZERO

func set_gate(g: Node) -> void:
	g.get_node("GateBody").set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	g.get_node("AnimatedSprite2D").play("close")
	SFX.play("gate_close")

func _on_satan_defeated() -> void:
	await satan.tree_exited
	var dialog = get_tree().get_first_node_in_group("dialog_box")
	await player.play_absorb_animation(null)
	player.absorbing = true
	player.anim.play("idle")
	quaking = true
	rockfall()
	dialog.dialog_start("Dante", lines_quake, false)
	await dialog.dialog_finished
	await walk_to($SatanSpawn.global_position.x)
	player.anim.play("cast")
	player.anim.play("freeze")
	SFX.play("ice_crack")
	await get_tree().create_timer(1.2).timeout

func rockfall() -> void:
	while quaking:
		var rock := FX.instantiate() as BossFx
		rock.anim_name = "rock"
		rock.gravity = 700.0
		rock.land_anim = "rock_break"
		rock.land_sfx = "rock_break"
		rock.position = Vector2(randf_range(80, 1200), 160)
		get_parent().add_child(rock)
		rock.hitbox.deactivate()
		player.shake(2.5)
		await get_tree().create_timer(0.3).timeout

func walk_to(x: float) -> void:
	var dir := signf(x - player.global_position.x)
	if dir == 0: return
	player.facing = int(dir)
	player.visual.scale.x = dir
	player.anim.play("run")
	var time := absf(x - player.global_position.x) / player.run_speed
	await create_tween().tween_property(player, "global_position:x", x, time).finished
	player.anim.play("idle")
