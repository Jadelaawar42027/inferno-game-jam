extends Boss
@export var charge_speed := 260.0
@export var stun_time := 1.8
@export var leap_height := -480.0
@onready var charge_hitbox: Hitbox = $ChargeHitbox
@onready var gore_hitbox: Hitbox = $GoreHitbox
@onready var lash_hitbox: Hitbox = $LashHitbox
var roar_pending := false

func _ready() -> void:
	super()
	gore_hitbox.hit_landed.connect(_on_gore_hit)

func get_attacks() -> Array[String]:
	var d := absf(dx_to_player())
	var list: Array[String] = ["pound"]
	if d > 120: list.append_array(["charge", "charge", "leap"])
	else: list.append_array(["gore", "lash", "lash"])
	return list

func do_attack(attack_name: String) -> void:
	if roar_pending:
		roar_pending = false
		await play_and_wait("roar")
	face_player()
	match attack_name:
		"charge": await bull_charge()
		"gore": await horn_gore()
		"pound": await ground_pound()
		"lash": await chain_lash()
		"leap": await leap_crush()

func on_phase_entered(_new_phase: int) -> void:
	roar_pending = true
	think_time *= 0.7

func set_facing(dir: float) -> void:
	super(dir)
	charge_hitbox.position.x = 35 * dir
	gore_hitbox.position.x = 55 * dir
	lash_hitbox.position.x = 70 * dir

func bull_charge() -> void:
	await play_and_wait("charge_windup")
	if is_dead: return
	var runs := 1 if phase == 1 else 3
	for r in runs:
		sprite.play("charge")
		charge_hitbox.activate()
		var t := 0.0
		while (t < 0.1 or not is_on_wall()) and t < 2.5 and not is_dead:
			velocity.x = direction * charge_speed
			t += get_physics_process_delta_time()
			await get_tree().physics_frame
		velocity.x = 0
		charge_hitbox.deactivate()
		if is_dead: return
		if r < runs - 1:
			set_facing(-direction)
			await wait(0.25)
			if is_dead: return
	spawn_rocks(3)
	await play_and_wait("charge_crash")
	if is_dead: return
	sprite.play("stun")
	await wait(stun_time)

func horn_gore() -> void:
	await play_and_wait("gore_windup")
	if is_dead: return
	sprite.play("gore")
	gore_hitbox.activate()
	await wait(0.15)
	gore_hitbox.deactivate()
	if is_dead: return
	await sprite.animation_finished

func _on_gore_hit(_hurtbox: Hurtbox) -> void:
	player_target.velocity = Vector2(direction * 120, -380)

func ground_pound() -> void:
	await play_and_wait("pound_windup")
	if is_dead: return
	sprite.play("pound")
	spawn_fx("shockwave", global_position + Vector2(40, 50), Vector2(180, 0))
	spawn_fx("shockwave", global_position + Vector2(-40, 50), Vector2(-180, 0))
	spawn_rocks(4 if phase == 1 else 7)
	await sprite.animation_finished

func spawn_rocks(count: int) -> void:
	for i in count:
		if is_dead: return
		var x := player_target.global_position.x + randf_range(-100, 100)
		spawn_fx("warning", Vector2(x, global_position.y + 50))
		var r := spawn_fx("rock", Vector2(x, global_position.y - 220))
		r.gravity = 700.0
		r.land_anim = "rock_break"
		r.harmless_on_land = true
		await wait(0.15)

func chain_lash() -> void:
	await play_and_wait("lash_windup")
	if is_dead: return
	sprite.play("lash")
	await wait(0.07)
	lash_hitbox.activate()
	await wait(0.15)
	lash_hitbox.deactivate()
	if is_dead: return
	await sprite.animation_finished

func leap_crush() -> void:
	await play_and_wait("leap_windup")
	if is_dead: return
	sprite.play("leap")
	velocity = Vector2(clampf(dx_to_player() * 1.4, -220, 220), leap_height)
	await wait(0.1)
	while not is_on_floor() and not is_dead: await get_tree().physics_frame
	velocity.x = 0
	if is_dead: return
	spawn_fx("shockwave", global_position + Vector2(40, 50), Vector2(200, 0))
	spawn_fx("shockwave", global_position + Vector2(-40, 50), Vector2(-200, 0))
	await play_and_wait("leap_land")
