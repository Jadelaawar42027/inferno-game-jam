extends Enemy

class_name Boss

signal boss_started
signal phase_changed(new_phase: int)
signal boss_defeated

@export var boss_name := "Boss"
@export var phase_thresholds: Array[float] = [0.5]
@export var recover_time := 0.8
@export var auto_start := false 
@export var reward: Ability

var phase := 1
var active := false
var last_attack := ""

func _ready() -> void:
	super()
	health.health_changed.connect(_on_health_changed)
	if auto_start:
		await get_tree().process_frame
		activate(get_tree().get_first_node_in_group("player"))

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if not active: velocity.x = 0
	move_and_slide()

func activate(p: Player) -> void:
	if active or is_dead or p == null: return
	player_target = p
	active = true
	boss_started.emit()
	brain()

func brain() -> void:
	while active and not is_dead:
		if player_target.is_invisible:
			play_anim("idle")
			await wait(0.2)
			continue
		var attack := pick_attack()
		if attack == "": return
		last_attack = attack
		await do_attack(attack)
		if is_dead: return
		velocity.x = 0
		play_anim("idle")
		await wait(recover_time)

func pick_attack() -> String:
	var options := get_attacks()
	if options.is_empty(): return ""
	if options.size() > 1: options.erase(last_attack)
	return options.pick_random()

func get_attacks() -> Array[String]:
	return []

func do_attack(_attack_name: String) -> void:
	await wait(0.1)

func _on_health_changed(current: int, max_hp: int) -> void:
	if is_dead: return
	var ratio := float(current) / max_hp
	var next := 1
	for i in phase_thresholds.size():
		if ratio <= phase_thresholds[i]: next = i + 2
	if next > phase:
		phase = next
		phase_changed.emit(phase)
		on_phase_entered(phase)

func on_phase_entered(_new_phase: int) -> void:
	pass

func die() -> void:
	if is_dead: return
	is_dead = true
	active = false
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitorable", false)
	$ContactHitbox.deactivate()
	boss_defeated.emit()
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	GameState.absorb(reward)
	queue_free()

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, false).timeout

func dx_to_player() -> float:
	return player_target.global_position.x - global_position.x

func face_player() -> void:
	var dx := dx_to_player()
	if dx != 0: set_facing(signf(dx))

func play_and_wait(anim_name: String, fallback := 0.4) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.stop()
		sprite.play(anim_name)
		await sprite.animation_finished
	else: await wait(fallback)
