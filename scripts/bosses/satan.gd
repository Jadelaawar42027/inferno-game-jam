extends Boss

const PILLAR := preload("res://scenes/bosses/ice_pillar.tscn")

@export var charge_speed := 320.0
@export var swoop_speed := 340.0
@export var fly_time := 6.0

@onready var claw_hitbox: Hitbox = $ClawHitbox
@onready var tail_hitbox: Hitbox = $TailHitbox
@onready var charge_hitbox: Hitbox = $ChargeHitbox
@onready var slam_hitbox: Hitbox = $SlamHitbox
@onready var beam_pivot: Node2D = $BeamPivot
@onready var beam_hitbox: Hitbox = $BeamPivot/BeamHitbox

var flying := false
var weak_point := false
var final_done := false
var floor_y := 0.0
var stunned := false

func _ready() -> void:
	super()
	sprite.play("frozen")

func activate(p: Player) -> void:
	floor_y = global_position.y
	super(p)

func die() -> void:
	flying = false
	super()

func _physics_process(delta: float) -> void:
	if flying: return
	super(delta)

func play_anim(anim_name: String) -> void:
	if anim_name == "idle" and phase == 3: anim_name = "idle_p3"
	super(anim_name)
	
func set_facing(dir: float) -> void:
	super(dir)
	claw_hitbox.position.x = 60 * dir
	tail_hitbox.position.x = 40 * dir
	charge_hitbox.position.x = 40 * dir
	
func get_attacks() -> Array[String]:
	if phase == 3 and health.current_health <= health.max_health * 0.1 and not final_done: return ["final"]
	var d := absf(dx_to_player())
	var list: Array[String] = ["slam"]
	if d < 110: list.append_array(["claw", "claw", "tail"])
	else: list.append("charge")
	if phase == 3: list.append_array(["breath", "orbs", "beam", "roar", "combo"])
	if phase == 2: list.append_array(["flight", "flight"])
	if phase == 3: list.append("flight")
	return list

func do_attack(attack_name: String) -> void:
	face_player()
	match attack_name:
		"claw": await claw()
		"tail": await tail()
		"slam": await slam()
		"charge": await charge()
		"flight": await flight()
		"breath": await breath()
		"orbs": await orbs()
		"beam": await beam()
		"roar": await roar()
		"combo": await combo()
		"final": await final_stand()
		
func on_phase_entered(new_phase: int) -> void:
	think_time *= 0.75
	if new_phase == 2:
		var gold := player_target.ability_manager.get_behavior(&"gold_throw") as GoldThrowBehavior
		if gold: gold.ammo = gold.max_ammo

func hit_window(hb: Hitbox, frame: int, length := 0.12) -> void:
	while sprite.frame < frame and not is_dead: await get_tree().process_frame
	if is_dead: return
	hb.activate()
	await wait(length)
	hb.deactivate()

func claw() -> void:
	sprite.play("claw")
	await hit_window(claw_hitbox, 1)
	await hit_window(claw_hitbox, 3)
	if sprite.is_playing(): await sprite.animation_finished
	await wait(0.5)

func tail() -> void:
	sprite.play("tail")
	await hit_window(tail_hitbox, 2)
	if sprite.is_playing(): await sprite.animation_finished

func slam() -> void:
	slam_hitbox.damage = 1
	sprite.play("slam")
	while sprite.frame < 2 and not is_dead: await get_tree().process_frame
	slam_hitbox.activate()
	spawn_fx("shockwave", global_position + Vector2(40, 0), Vector2(200, 0))
	spawn_fx("shockwave", global_position + Vector2(-40, 0), Vector2(-200, 0))
	await wait(0.1)
	slam_hitbox.deactivate()
	if sprite.is_playing(): await sprite.animation_finished

func charge() -> void:
	sprite.play("charge")
	charge_hitbox.activate()
	var t := 0.0
	while (t < 0.1 or not is_on_wall()) and t < 1.6 and not is_dead:
		velocity.x = direction * charge_speed
		if sprite.frame >= 3: sprite.frame = 1
		t += get_physics_process_delta_time()
		await get_tree().physics_frame
	velocity.x = 0
	charge_hitbox.deactivate()

func flight() -> void:
	await play_and_wait("takeoff")
	flying = true
	velocity = Vector2.ZERO
	sprite.play("fly")
	var hover := get_node_or_null("../Fight/HoverCenter") as Marker2D
	var top := hover.global_position if hover else global_position + Vector2(0, -150)
	await create_tween().tween_property(self, "global_position", top, 0.5).finished
	var left := fly_time
	while left > 0 and not is_dead:
		face_player()
		if randf() < 0.6: 
			left -= 1.5 
			await swoop()
		else: 
			left -= 1.5
			await gust()
		if not is_dead: sprite.play("fly")
		await wait(0.6)
		left -= 0.6
	if is_dead: return
	await land()

func swoop() -> void:
	sprite.play("swoop")
	await wait(0.25)
	charge_hitbox.activate()
	var target := player_target.global_position + Vector2(0, -20)
	await create_tween().tween_property(self, "global_position", target, global_position.distance_to(target) / swoop_speed).finished
	charge_hitbox.deactivate()
	var up := global_position + Vector2(-direction * 120, -150)
	up.y = maxf(up.y, floor_y - 200)
	await create_tween().tween_property(self, "global_position", up, 0.4).finished

func gust() -> void:
	sprite.play("gust")
	await wait(0.2)
	player_target.velocity.x = direction * 260
	player_target.hurt_lock_timer = 0.35
	for i in 5:
		var x := player_target.global_position.x + randf_range(-120, 120)
		spawn_fx("warning", Vector2(x, floor_y))
		var r := spawn_fx("rock", Vector2(x, floor_y - 260))
		r.gravity = 700.0
		r.land_anim = "rock_break"
		r.harmless_on_land = true
		await wait(0.15)
	if sprite.is_playing(): await sprite.animation_finished

func land() -> void:
	sprite.play("land")
	var down := Vector2(clampf(player_target.global_position.x, global_position.x - 150, global_position.x + 150), floor_y)
	await create_tween().tween_property(self, "global_position", down, 0.3).finished
	flying = false
	slam_hitbox.activate()
	spawn_fx("shockwave", global_position + Vector2(40, 0), Vector2(220, 0))
	spawn_fx("shockwave", global_position + Vector2(-40, 0), Vector2(-220, 0))
	await wait(0.1)
	slam_hitbox.deactivate()
	if sprite.is_playing(): await sprite.animation_finished
	await wait(1.0)

func breath() -> void:
	sprite.play("breath")
	while sprite.frame < 1 and not is_dead: await get_tree().process_frame
	for i in 4:
		spawn_fx("puddle", global_position + Vector2(direction * (50 + i * 40), 0))
		await wait(0.08)
	if sprite.is_playing(): await sprite.animation_finished

func orbs() -> void:
	sprite.play("orbs")
	while sprite.frame < 2 and not is_dead: await get_tree().process_frame
	for i in 3:
		var aim := player_target.global_position + Vector2(0, -12)
		if player_target.is_invisible: aim += Vector2(randf_range(-150, 150), 0)
		var from := global_position + Vector2(direction * 40, -120)
		var o := spawn_fx("venom", from, (aim - from).normalized() * 160)
		get_tree().create_timer(3.0, false).timeout.connect(o.queue_free)
		await wait(0.3)
	if sprite.is_playing(): await sprite.animation_finished

func beam() -> void:
	sprite.play("beam")
	var start := (player_target.global_position - beam_pivot.global_position).angle() - 0.6 * direction
	beam_pivot.rotation = start
	$BeamPivot/Beam.visible = true
	if not player_target.is_invisible: beam_hitbox.activate()
	await create_tween().tween_property(beam_pivot, "rotation", start + 1.2 * direction, 0.9).finished
	beam_hitbox.deactivate()
	$BeamPivot/Beam.visible = false
	if sprite.is_playing(): await sprite.animation_finished

func roar() -> void:
	sprite.play("roar")
	for m in ["Pillar1", "Pillar2", "Pillar3", "Pillar4"]:
		var spot := get_node_or_null("../Fight/" + m) as Marker2D
		if spot == null: continue
		var p := PILLAR.instantiate()
		get_parent().add_child(p)
		p.global_position = spot.global_position
	if sprite.is_playing(): await sprite.animation_finished

func combo() -> void:
	charge_hitbox.damage = 2
	slam_hitbox.damage = 2
	await charge()
	if is_dead: return
	flying = true
	await swoop()
	if is_dead: return
	await land()
	charge_hitbox.damage = 1
	slam_hitbox.damage = 1

func final_stand() -> void:
	final_done = true
	flying = true
	await create_tween().tween_property(self, "global_position", global_position + Vector2(0, -120), 0.5).finished
	await play_and_wait("chest_open")
	weak_point = true
	await wait(2.5)
	if stunned:
		await wait(2.0)
		stunned = false
		return
	if weak_point:
		weak_point = false
		final_done = false
		slam_hitbox.damage = 2
		await land()
		slam_hitbox.damage = 1

func _on_hurt(hb: Hitbox) -> void:
	super(hb)
	if weak_point and hb.damage >= 3:
		weak_point = false
		stunned = true
		flying = false
		create_tween().tween_property(self, "global_position:y", floor_y, 0.3)
		sprite.play("stunned")
