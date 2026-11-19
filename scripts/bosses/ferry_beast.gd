extends Boss

const P2_FRAMES := preload("res://assets/sprites/bosses/ferry_beast/ferry_beast_p2_frames.tres")

@export var lunge_speed := 300.0
@export var stuck_time := 1.2
@export var stun_time := 1.5
@onready var sting_hitbox: Hitbox = $StingHitbox
@onready var swipe_hitbox: Hitbox = $SwipeHitbox
@onready var lunge_hitbox: Hitbox = $LungeHitbox

var reveal_pending := false
var faking := false
var fake_hit := false

func get_attacks() -> Array[String]:
	var d := absf(dx_to_player())
	var list: Array[String] = ["spray"]
	if d < 130: list.append_array(["sting", "swipe", "swipe"])
	else: list.append_array(["lunge", "lunge"])
	if phase == 1: list.append_array(["lie", "fake"])
	return list

func do_attack(attack_name: String) -> void:
	if reveal_pending:
		reveal_pending = false
		sfx("roar")
		await play_and_wait("reveal")
		if is_dead: return
		sprite.sprite_frames = P2_FRAMES
		sprite.play("idle")
	face_player()
	match attack_name:
		"sting": await tail_sting()
		"swipe": await paw_swipe()
		"spray": await venom_spray()
		"lunge": await slither_lunge()
		"lie": await the_lie()
		"fake": await false_opening()

func on_phase_entered(_new_phase: int) -> void:
	reveal_pending = true
	think_time *= 0.7
	stuck_time *= 0.5

func set_facing(dir: float) -> void:
	super(dir)
	sting_hitbox.position.x = 70 * dir
	swipe_hitbox.position.x = 72 * dir
	lunge_hitbox.position.x = 60 * dir

func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if faking: fake_hit = true

func tail_sting(skip_windup := false) -> void:
	var stings := 1 if phase == 1 else 2
	for s in stings:
		face_player()
		if not skip_windup or s > 0:
			await play_and_wait("sting_windup")
			if is_dead: return
		sprite.play("sting")
		await wait(0.07)
		sting_hitbox.activate()
		sfx("sting")
		await sprite.animation_finished
		sting_hitbox.deactivate()
		if is_dead: return
		sprite.play("sting_stuck")
		await wait(stuck_time)
		if is_dead: return
		await play_and_wait("sting_recover")
		if is_dead: return

func paw_swipe(skip_windup := false) -> void:
	if not skip_windup:
		await play_and_wait("swipe_windup")
		if is_dead: return
	sprite.play("swipe")
	swipe_hitbox.activate()
	sfx("swipe")
	await wait(0.1)
	swipe_hitbox.deactivate()
	await wait(0.08)
	if is_dead: return
	swipe_hitbox.activate()
	await wait(0.1)
	swipe_hitbox.deactivate()
	if is_dead: return
	await sprite.animation_finished

func venom_spray(skip_windup := false) -> void:
	if not skip_windup:
		await play_and_wait("spray_windup")
		if is_dead: return
	sprite.play("spray")
	sfx("spray")
	var vx := clampf(dx_to_player() / 0.9, -220, 220)
	for spread in [-40.0, 0.0, 40.0]:
		var g := spawn_fx("venom", global_position + Vector2(direction * 50, -60), Vector2(vx + spread, -250))
		g.gravity = 500.0
		g.land_anim = "puddle"
		g.land_sfx = sfx_key("venom_puddle")
	await sprite.animation_finished

func slither_lunge(skip_windup := false) -> void:
	if not skip_windup:
		await play_and_wait("lunge_windup")
		if is_dead: return
	sprite.play("lunge")
	lunge_hitbox.activate()
	var t := 0.0
	while (t < 0.1 or not is_on_wall()) and t < 1.2 and not is_dead:
		velocity.x = direction * lunge_speed
		t += get_physics_process_delta_time()
		await get_tree().physics_frame
	var hit_wall := is_on_wall()
	velocity.x = 0
	lunge_hitbox.deactivate()
	if is_dead: return
	await play_and_wait("lunge_end")
	if hit_wall and not is_dead:
		sprite.play("stun")
		await wait(stun_time)

func the_lie() -> void:
	var fake: String = ["sting", "swipe", "lunge"].pick_random()
	await play_and_wait(fake + "_windup_lie")
	if is_dead: return
	var options: Array[String] = ["sting", "swipe", "lunge", "spray"]
	options.erase(fake)
	match options.pick_random():
		"sting": await tail_sting(true)
		"swipe": await paw_swipe(true)
		"lunge": await slither_lunge(true)
		"spray": await venom_spray(true)

func false_opening() -> void:
	sprite.play("fake_stun")
	sfx("fake")
	faking = true
	fake_hit = false
	var t := 0.0
	while t < 1.5 and not fake_hit and not is_dead:
		t += get_physics_process_delta_time()
		await get_tree().physics_frame
	faking = false
	if fake_hit and not is_dead: await tail_sting(true)
