extends Boss

@export var touch_speed := 220.0
@export var freeze_time := 1.0
@export var guard_time := 1.5
@export var down_time := 1.6
@onready var touch_hitbox: Hitbox = $TouchHitbox
@onready var topple_hitbox: Hitbox = $ToppleHitbox
var roar_pending := false
var guarding := false
var guard_hit := false

func _ready() -> void:
	hurtbox.monitoring = true
	hurtbox.set_collision_mask_value(4, true)
	super()
	touch_hitbox.hit_landed.connect(_on_touch_hit)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func get_attacks() -> Array[String]:
	var d := absf(dx_to_player())
	var list: Array[String] = ["stomp", "rain"]
	if d < 150: list.append_array(["touch", "touch", "topple"])
	if d < 90: list.append("guard")
	return list

func do_attack(attack_name: String) -> void:
	if roar_pending:
		roar_pending = false
		await play_and_wait("roar")
	face_player()
	match attack_name:
		"touch": await golden_touch()
		"stomp": await statue_stomp()
		"rain": await coin_rain()
		"guard": await statue_guard()
		"topple": await topple()
		
func on_phase_entered(_new_phase: int) -> void:
	roar_pending = true
	think_time *= 0.7

func golden_touch() -> void:
	await play_and_wait("touch_windup")
	if is_dead: return
	touch_hitbox.position.x = 75 * direction
	sprite.play("touch")
	sfx("touch")
	touch_hitbox.activate()
	velocity.x = direction * touch_speed
	await wait(0.3)
	if is_dead: return
	velocity.x = 0
	touch_hitbox.deactivate()
	if sprite.is_playing(): await sprite.animation_finished
	await play_and_wait("touch_recover")
	if phase == 2 and not is_dead: await statue_stomp()

func _on_touch_hit(_hurtbox: Hurtbox) -> void:
	var p := player_target
	p.velocity = Vector2.ZERO
	p.hurt_lock_timer = freeze_time
	p.visual.modulate = Color(1.0, 0.8, 0.3, p.visual.modulate.a)
	await wait(freeze_time)
	if is_instance_valid(p): p.visual.modulate = Color(1, 1, 1, p.visual.modulate.a)

func statue_stomp() -> void:
	face_player()
	await play_and_wait("stomp_windup")
	if is_dead: return
	sprite.play("stomp")
	sfx("stomp")
	var count := 5 if phase == 1 else 7
	for i in count:
		if is_dead: return
		spawn_pillar(global_position + Vector2(direction * (60 + i * 40), 50))
		if phase == 2: spawn_pillar(global_position + Vector2(-direction * (60 + i * 40), 50))
		await wait(0.12)
	await wait(0.4)

func spawn_pillar(pos: Vector2) -> void:
	var p := spawn_fx("pillar_rise", pos)
	sfx("pillar")
	await p.sprite.animation_finished
	if not is_instance_valid(p): return
	p.sprite.play("pillar")
	await get_tree().create_timer(0.6, false).timeout
	if not is_instance_valid(p): return
	p.hitbox.deactivate()
	p.sprite.play("pillar_sink")
	await p.sprite.animation_finished
	if is_instance_valid(p): p.queue_free()

func coin_rain() -> void:
	await play_and_wait("rain_windup")
	if is_dead: return
	sprite.play("rain")
	sfx("coin_rain")
	var count := 8 if phase == 1 else 12
	for i in count:
		if is_dead: return
		var x := player_target.global_position.x + randf_range(-80, 80)
		spawn_fx("warning", Vector2(x, global_position.y + 50))
		var c := spawn_fx("coin", Vector2(x, global_position.y - 200))
		c.gravity = 900.0
		await wait(0.18)
	await wait(0.5)

func statue_guard() -> void:
	await play_and_wait("guard_start")
	if is_dead: return
	sprite.play("guard")
	sfx("guard")
	hurtbox.invulnerable = true
	guarding = true
	guard_hit = false
	await wait(guard_time)
	if is_dead: return
	guarding = false
	hurtbox.invulnerable = false
	if guard_hit and not is_dead:
		sprite.play("guard_counter")
		spawn_fx("shockwave", global_position + Vector2(30, 50), Vector2(180, 0))
		spawn_fx("shockwave", global_position + Vector2(-30, 50), Vector2(-180, 0))
		await sprite.animation_finished

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if guarding and area is Hitbox: guard_hit = true

func topple() -> void:
	face_player()
	await play_and_wait("topple_windup")
	if is_dead: return
	topple_hitbox.position.x = 55 * direction
	sprite.play("topple")
	await wait(0.08)
	if is_dead: return
	topple_hitbox.activate()
	await sprite.animation_finished
	if is_dead: return
	topple_hitbox.deactivate()
	sfx("topple")
	spawn_fx("shockwave", global_position + Vector2(direction * 110, 50), Vector2(direction * 180, 0))
	sprite.play("topple_down")
	await wait(down_time)
	if is_dead: return
	await play_and_wait("topple_rise")
