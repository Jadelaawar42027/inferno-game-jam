extends Enemy

class_name Boss

signal boss_started
signal phase_changed(new_phase: int)
signal boss_defeated


const FX_SCENE := preload("res://scenes/fx/boss_fx.tscn")

@export var boss_name := "Boss"
@export var phase_thresholds: Array[float] = [0.5]
@export var recover_time := 0.8
@export var auto_start := false 
@export var reward: Ability
@export var think_time := Vector2(0.6, 1.3)
@export var preferred_range := Vector2(60, 140)
@export var move_speed := 60.0
@export var reposition_time := 1.5
@export var intro_anim := "roar"
@export var voice_id := ""
@export var voice_pitch := 1.0
@export var intro_lines: Array[DialogLine]
@export var intro_roar_time := 2.0
@export var portrait: Texture2D
@export var death_lines: Array[DialogLine]
@export var guide_lines: Array[DialogLine]
@export var guide_name := "Virgil"
@export var guide_portrait: Texture2D
@export var sfx_prefix := ""

var intro_done := false
var phase := 1
var active := false
var last_attack := ""

func _ready() -> void:
	if reward and GameState.has_ability(reward.id):
		queue_free()
		return
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
	if not intro_done:
		say("intro")
		await play_and_wait(intro_anim)
	await wait(0.4)
	while active and not is_dead:
		if player_target.is_invisible:
			play_anim("idle")
			await wait(0.2)
			continue
		await reposition()
		if is_dead or not active: return
		var attack := pick_attack()
		if attack == "": return
		last_attack = attack
		await do_attack(attack)
		if is_dead: return
		velocity.x = 0
		play_anim("idle")
		await wait(randf_range(think_time.x, think_time.y))

func reposition() -> void:
	var t := 0.0
	play_anim("walk")
	while t < reposition_time and not is_dead:
		var d := dx_to_player()
		var dist := absf(d)
		if dist >= preferred_range.x and dist <= preferred_range.y: break
		var step := signf(d) if dist > preferred_range.y else -signf(d)
		velocity.x = step * move_speed
		set_facing(signf(d))
		t += get_physics_process_delta_time()
		await get_tree().physics_frame
	velocity.x = 0
	play_anim("idle")

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
		SFX.play("boss_phase")
		say("phase" + str(phase))
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
	for child in get_children():
		if child is Hitbox: child.deactivate()
	boss_defeated.emit()
	sfx("death")
	say("death")
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	await talk(death_lines)
	await talk(guide_lines, guide_name, guide_portrait)
	if reward: GameState.absorb(reward)
	queue_free()

func wait(seconds: float) -> void:
	if not is_inside_tree():
		return
	await get_tree().create_timer(seconds, false).timeout

func dx_to_player() -> float:
	return player_target.global_position.x - global_position.x

func face_player() -> void:
	var dx := dx_to_player()
	if dx != 0: set_facing(signf(dx))

func play_and_wait(anim_name: String, fallback := 0.4) -> void:
	if anim_name == "roar": sfx("roar")
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.stop()
		sprite.play(anim_name)
		await sprite.animation_finished
	else: await wait(fallback)

func spawn_fx(anim: String, pos: Vector2, vel := Vector2.ZERO) -> BossFx:
	if anim == "shockwave" or anim == "warning": SFX.play(anim)
	var fx := FX_SCENE.instantiate() as BossFx
	fx.anim_name = anim
	fx.velocity = vel
	fx.position = pos
	get_parent().add_child(fx)
	return fx

func _on_hurt(_hitbox: Hitbox) -> void:
	if is_dead: return
	on_hit_flash()
	SFX.play("boss_hurt")
	if randf() < 0.3: say("hurt", false)

func say(moment: String, interrupt := true) -> void:
	if voice_id == "": return
	VoiceManager.play_line(voice_id + "_" + moment, "Boss Voice", voice_pitch, interrupt)

func play_intro(p: Player) -> void:
	player_target = p
	intro_done = true
	face_player()
	say("intro")
	sfx("roar")
	var has_roar: bool = sprite.sprite_frames != null and sprite.sprite_frames.has_animation(intro_anim)
	var left := intro_roar_time
	while left > 0.0 and not is_dead:
		if has_roar and (not sprite.is_playing() or sprite.animation != intro_anim):
			sprite.play(intro_anim)
		left -= get_physics_process_delta_time()
		await get_tree().physics_frame
	play_anim("idle")
	if intro_lines.is_empty():
		return
	var dialog = get_tree().get_first_node_in_group("dialog_box")
	if dialog == null:
		return
	dialog.dialog_start(boss_name, intro_lines, false, portrait)
	await dialog.dialog_finished

func _exit_tree() -> void:
	active = false
	is_dead = true

func talk(lines: Array[DialogLine], speaker := "", pic: Texture2D = null) -> void:
	var dialog := get_tree().get_first_node_in_group("dialog_box")
	if dialog == null or lines.is_empty(): return
	if speaker == "": speaker = boss_name
	if pic == null: pic = portrait
	dialog.dialog_start(speaker, lines, true, pic)
	await dialog.dialog_finished

func sfx_key(sound: String) -> String:
	var own := sfx_prefix + "_" + sound
	return own if SFX.sounds.has(own) else sound

func sfx(sound: String) -> void:
	SFX.play(sfx_key(sound))
