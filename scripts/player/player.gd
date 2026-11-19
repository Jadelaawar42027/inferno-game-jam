extends CharacterBody2D

class_name Player

signal absorb_finished(ability: Ability)

@onready var visual: Node2D = $Visual

@export_group("Movement")
@export var run_speed :float = 150
@export var jump_velocity :float = -330
@export var rise_gravity :float = 900
@export var fall_gravity :float = 1600
@export var max_fall_speed :float = 420
@export var jump_cut_multiplier :float = 0.4
@export var coyote_time :float = 0.1
@export var jump_buffer_time :float = 0.1

@export_group("Combat")
@export var attack_cooldown: float = 0.35
@export var attack_active_time: float = 0.1
@export var recoil_speed: float = 120.0
@export var recoil_time: float = 0.08
@export var pogo_velocity: float = -300.0
@export var hurt_knockback := Vector2(180, -150)
@export var invincibility_time: float = 1.0
@export var hurt_control_lock: float = 0.2

@onready var side_slash: Hitbox = $Attacks/SideSlash
@onready var up_slash: Hitbox = $Attacks/UpSlash
@onready var down_slash: Hitbox = $Attacks/DownSlash

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: HealthComponent = $health_component

@onready var anim: AnimatedSprite2D = $Visual/AnimatedSprite2D
@onready var breath_puff: CPUParticles2D = $Visual/BreathPuff

@onready var camera: Camera2D = $Camera2D

@onready var ability_manager: AbilityManager = $AbilityManager
@onready var eye_mat := anim.material as ShaderMaterial

@onready var footsteps: AudioStreamPlayer2D = $Footsteps

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var facing := 1
var absorbing := false

var cutscene_lock := false

var attack_cooldown_timer := 0.0
var attack_active_timer := 0.0
var recoil_timer := 0.0
var hurt_lock_timer := 0.0
var invincibility_timer := 0.0
var active_hitbox: Hitbox = null
var shake_strength := 0.0
var last_dir := 0.0

var action_lock := false
var was_on_floor := true
var fall_speed_peak := 0.0

var is_invisible := false

@export var hard_land_speed := 600.0
var slash_combo := 0
var is_dead = false

func start_attack(dir: float) -> void:
	if dir != 0:
		facing = int(dir)
		visual.scale.x = facing
	if Input.is_action_pressed("move_up"): 
		active_hitbox = up_slash
		play_action("slash_up")
	elif Input.is_action_pressed("move_down") and not is_on_floor(): 
		active_hitbox = down_slash
		play_action("slash_down")
	else:
		active_hitbox = side_slash
		side_slash.position.x = facing * 19
		play_action("slash_side" if slash_combo == 0 else "slash_side_alt")
		slash_combo = 1 - slash_combo
	active_hitbox.activate()
	var fx: AnimatedSprite2D = active_hitbox.get_node("SlashFX")
	fx.flip_h = facing < 0
	fx.flip_v = active_hitbox == side_slash and slash_combo == 1
	fx.show()
	fx.modulate = Color.WHITE.lerp(Color(1, 0.3, 0.35), GameState.corruption())
	fx.stop()
	fx.play("slash")
	SFX.play("slash")
	attack_active_timer = attack_active_time
	attack_cooldown_timer = attack_cooldown
	VoiceManager.play_line("dante_attack", "Voice", randf_range(0.95, 1.05), false)

func end_attack() -> void:
	if active_hitbox == null: return
	active_hitbox.deactivate()
	active_hitbox = null

func _physics_process(delta: float) -> void:
	attack_cooldown_timer -= delta
	attack_active_timer -= delta
	recoil_timer -= delta
	hurt_lock_timer -= delta
	invincibility_timer -= delta
	
	if absorbing or is_dead or cutscene_lock:
		velocity.x = 0
		velocity.y = minf(velocity.y + fall_gravity * delta, max_fall_speed)
		if cutscene_lock and is_on_floor() and anim.animation != "idle":
			action_lock = false
			anim.play("idle")
		footsteps.stop()
		move_and_slide()
		return
	
	if is_on_floor():
		coyote_timer = coyote_time
	else: 
		coyote_timer -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	
	if velocity.y < 0 and Input.is_action_pressed("jump"):
		velocity.y += rise_gravity * delta
	else:
		velocity.y += fall_gravity * delta
		velocity.y = minf(velocity.y, max_fall_speed)
		
	var direction: float = get_move_dir()
	if hurt_lock_timer > 0:
		pass
	elif recoil_timer > 0:
		velocity.x = -facing * recoil_speed
	else:
		velocity.x = run_speed * direction
	
	if hurt_lock_timer <= 0:
		if jump_buffer_timer > 0 and coyote_timer > 0:
			velocity.y = jump_velocity
			jump_buffer_timer = 0
			coyote_timer = 0
			
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cut_multiplier
	
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0 and hurt_lock_timer <= 0:
		start_attack(direction)
	
	if active_hitbox != null and attack_active_timer <= 0:
		end_attack()
	
	if not is_on_floor():
		fall_speed_peak = max(fall_speed_peak, velocity.y)
	
	ability_manager.physics_update(delta)
	move_and_slide()
	
	if direction != 0 and hurt_lock_timer <= 0 and not action_lock:
		facing = int(direction)
		visual.scale.x = facing
	
	if invincibility_timer > 0:
		visual.visible = int(invincibility_timer * 10) % 2 == 0
	elif hurtbox.invulnerable:
		visual.visible = true
		hurtbox.invulnerable = false
	update_animation()
	var running := is_on_floor() and absf(velocity.x) > 10.0
	if running and not footsteps.playing: footsteps.play()
	elif not running: footsteps.stop()
	was_on_floor = is_on_floor()

func _on_slash_hit(_hurtbox: Hurtbox, slash: Hitbox)->void:
	SFX.play("slash_hit")
	if slash == down_slash: 
		SFX.play("pogo")
		velocity.y = pogo_velocity
		play_action("pogo")
	elif slash == side_slash: recoil_timer = recoil_time
	hit_stop(0.05)
	shake(2.0)

func _on_hurt(hitbox: Hitbox) ->void:
	if health.current_health <= 0: return
	var dir := signf(global_position.x - hitbox.global_position.x)
	if dir == 0: dir = -facing
	velocity = Vector2(dir * hurt_knockback.x, hurt_knockback.y)
	hurt_lock_timer = hurt_control_lock
	invincibility_timer = invincibility_time
	hurtbox.invulnerable = true
	end_attack()
	play_action("recoil")
	SFX.play("player_hurt")
	VoiceManager.play_line("dante_hurt", "Voice", 1.0, false)
	hit_stop(0.1)
	shake(5.0)

func _on_died() ->void:
	if is_dead: return
	is_dead = true
	Engine.time_scale = 1.0
	end_attack()
	play_action("death")
	SFX.play("player_death")
	VoiceManager.play_line("dante_death")
	await get_tree().create_timer(0.8).timeout
	GameState.reload_floor()

func hit_stop(duration: float) ->void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func shake(strength: float)->void:
	shake_strength = maxf(shake_strength, strength)
	
func _process(delta: float) -> void:
	if shake_strength > 0:
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
		shake_strength = move_toward(shake_strength, 0.0, 30.0 * delta)
	else:
		camera.offset = Vector2.ZERO

func _ready() -> void:
	Engine.time_scale = 1.0
	side_slash.hit_landed.connect(_on_slash_hit.bind(side_slash))
	up_slash.hit_landed.connect(_on_slash_hit.bind(up_slash))
	down_slash.hit_landed.connect(_on_slash_hit.bind(down_slash))
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)
	anim.animation_finished.connect(_on_anim_finished)
	anim.frame_changed.connect(_on_frame_changed)
	anim.play("idle")
	add_to_group("player")
	if GameState.checkpoint != Vector2.INF: 
		global_position = GameState.checkpoint
		camera.reset_smoothing()
	eye_mat.set_shader_parameter("corruption", GameState.corruption())
	for h in [side_slash, up_slash, down_slash]:
		var fx: AnimatedSprite2D = h.get_node("SlashFX")
		fx.animation_finished.connect(fx.hide)

func _on_anim_finished()->void:
	if anim.animation == "run_start": anim.play("run"); return
	if anim.animation == "stop": anim.play("idle"); return
	if anim.animation == "death": return
	action_lock = false

func _on_frame_changed():
	if anim.animation == "idle" and anim.frame == 2: breath_puff.restart()

func play_action(anim_name: String)->void:
	action_lock = true
	anim.stop()
	anim.play(anim_name)

func update_animation()-> void:
	if is_dead or action_lock:
		return
	if is_on_floor() and not was_on_floor:
		if fall_speed_peak > hard_land_speed:
			play_action("hard_land")
		else:
			play_action("land")
		fall_speed_peak = 0.0
		SFX.play("land")
		return
	if not is_on_floor() and velocity.y < 0: anim.play("jump"); return
	if not is_on_floor(): anim.play("fall"); return
	if abs(velocity.x) > 10.0:
		if anim.animation in ["idle", "stop", "look_up", "look_down"]:
			anim.play("run_start")
		elif anim.animation != "run_start": anim.play("run")
	else:
		if Input.is_action_pressed("move_up"): anim.play("look_up")
		elif Input.is_action_pressed("move_down"): anim.play("look_down")
		elif anim.animation in ["run", "run_start"]: anim.play("stop")
		elif anim.animation != "stop": anim.play("idle")

func get_move_dir() -> float:
	if Input.is_action_just_pressed("move_right"): last_dir = 1.0
	if Input.is_action_just_pressed("move_left"): last_dir = -1.0
	var right := Input.is_action_pressed("move_right")
	var left := Input.is_action_pressed("move_left")
	if right and left: return last_dir
	if right: return 1.0
	if left: return -1.0
	return 0.0

func play_absorb_animation(ability: Ability) -> void:
	absorbing = true
	end_attack()
	hurtbox.invulnerable = true
	var cam_tween := create_tween()
	cam_tween.tween_property(camera, "zoom", camera.zoom * 1.3, 0.4)
	play_action("absorb")
	SFX.play("absorb")
	await anim.animation_finished
	set_corruption_smooth()
	shake(4.0)
	var back := create_tween()
	back.tween_property(camera, "zoom", camera.zoom / 1.3, 0.5)
	hurtbox.invulnerable = false
	absorbing = false
	absorb_finished.emit(ability)

func set_corruption_smooth() -> void:
	var from: float = eye_mat.get_shader_parameter("corruption")
	var t := create_tween()
	t.tween_method(func(v: float): eye_mat.set_shader_parameter("corruption", v), from, GameState.corruption(), 1.2)
