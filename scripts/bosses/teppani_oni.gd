extends Boss

@export var hop_speed := 140.0
@export var hop_height := -380.0
@export var heal_amount := 4

@onready var knife_hitbox: Hitbox = $KnifeHitbox

var roar_pending := false

func get_attacks() -> Array[String]:
	var d := absf(dx_to_player())
	var list: Array[String] = []
	if d < 110: list.append_array(["knives", "knives", "slam"])
	else: list.append_array(["toss", "slam"])
	if d > 60 and d < 200: list.append("flambe")
	if health.current_health < health.max_health and not get_tree().get_nodes_in_group("meatballs").is_empty(): list.append("eat")
	return list

func do_attack(attack_name: String) -> void:
	if roar_pending:
		roar_pending = false
		await play_and_wait("roar")
	face_player()
	match attack_name:
		"slam": await belly_slam()
		"knives": await knife_flurry()
		"flambe": await flambe()
		"toss": await meatball_toss()
		"eat": await snack()

func on_phase_entered(_new_phase: int) -> void:
	roar_pending = true

func belly_slam() -> void:
	var hops := 4 if phase == 1 else 5
	for i in hops:
		if is_dead: return
		face_player()
		await play_and_wait("jump_windup")
		sprite.play("jump")
		velocity = Vector2(clampf(dx_to_player() * 1.3, -hop_speed, hop_speed), hop_height)
		await wait(0.1)
		while not is_on_floor() and not is_dead: await get_tree().physics_frame
		velocity.x = 0
		spawn_fx("shockwave", global_position + Vector2(30, 50), Vector2(160, 0))
		spawn_fx("shockwave", global_position + Vector2(-30, 50), Vector2(-160, 0))
		await play_and_wait("slam_land")

func knife_flurry() -> void:
	await play_and_wait("knife_draw")
	sprite.play("knife_flurry")
	knife_hitbox.position.x = 75 * direction
	var cuts := 6 if phase == 1 else 9
	for i in cuts:
		if is_dead: return
		knife_hitbox.activate()
		velocity.x = direction * 30
		await wait(0.125)
		knife_hitbox.deactivate()
		await wait(0.065)
	velocity.x = 0
	await play_and_wait("knife_sheath")

func flambe() -> void:
	await play_and_wait("flambe_windup")
	sprite.play("flambe")
	var patches := 4 if phase == 1 else 6
	for i in patches:
		spawn_fx("fire", global_position + Vector2(direction * (60 + i * 28), 50))
		await wait(0.15)
	await wait(0.4)

func meatball_toss() -> void:
	for i in 3:
		if is_dead: return
		face_player()
		await play_and_wait("toss_windup")
		sprite.play("toss")
		var fx := spawn_fx("meatball", global_position + Vector2(direction * 40, -40), Vector2(direction * randf_range(90, 180), -280))
		fx.gravity = 700.0
		fx.land_anim = "meatball_idle"
		fx.harmless_on_land = true
		fx.add_to_group("meatballs")
		await sprite.animation_finished

func snack() -> void:
	var balls := get_tree().get_nodes_in_group("meatballs")
	if balls.is_empty(): return
	var target: Node2D = balls[0]
	for b in balls:
		if absf(b.global_position.x - global_position.x) < absf(target.global_position.x - global_position.x): target = b
	sprite.play("walk")
	var t := 0.0
	while is_instance_valid(target) and absf(target.global_position.x - global_position.x) > 30 and t < 3.0 and not is_dead:
		set_facing(signf(target.global_position.x - global_position.x))
		velocity.x = direction * walk_speed * 3
		t += get_physics_process_delta_time()
		await get_tree().physics_frame
	velocity.x = 0
	if not is_instance_valid(target): return
	sprite.play("eat")
	await wait(0.2)
	if is_instance_valid(target): target.queue_free()
	await sprite.animation_finished
	if is_dead: return
	health.heal(heal_amount)
