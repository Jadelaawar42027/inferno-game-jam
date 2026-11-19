extends Enemy


enum State { PATROL, HOVER, WINDUP, SWOOP }
var state := State.PATROL

@export var patrol_range := 40.0
@export var bob_height := 4.0
@export var bob_speed := 3.0
@export var windup_time := 0.5
@export var swoop_speed := 160.0
@export var swoop_time := 0.6
@export var cooldown := 2.5
@export var hover_distance := 40.0
@export var hover_height_min := 55.0
@export var hover_height_max := 80.0
@export var hover_speed := 80.0
@export var orbit_speed := 1.5

var current_hover_height := 45.0
var orbit_time := 0.0
var state_timer := 0.0
var cooldown_timer := 0.0
var bob_time := 0.0
var home := Vector2.ZERO
var swoop_dir := Vector2.ZERO
var locked_target: Player = null


@onready var swoop_hitbox: Hitbox = $SwoopHitbox
@onready var detection_radius: Area2D = $DetectionRadius

func _ready() -> void:
	super()
	home = global_position
	detection_radius.body_entered.connect(_on_detection_radius_body_entered)
	detection_radius.body_exited.connect(_on_detection_radius_body_exited)

func _physics_process(delta: float) -> void:
	if is_dead: return
	cooldown_timer -= delta
	state_timer -= delta
	match state:
		State.PATROL: fly_patrol(delta)
		State.HOVER: hover(delta)
		State.WINDUP: windup()
		State.SWOOP: swoop()
	update_animation()
	move_and_slide()

func fly_patrol(delta: float) -> void:
	bob_time += delta
	velocity.x = direction * walk_speed
	var target_y := home.y + sin(bob_time * bob_speed) * bob_height
	velocity.y = (target_y - global_position.y) * 5.0
	var offset := global_position.x - home.x
	if is_on_wall() or (absf(offset) > patrol_range and signf(offset) == direction): set_facing(-direction)
	if player_in_range: 
		pick_hover_height()
		SFX.play("enemy_alert")
		state = State.HOVER

func start_windup() -> void:
	state = State.WINDUP
	state_timer = windup_time
	locked_target = player_target
	var dx := player_target.global_position.x - global_position.x
	if dx != 0: set_facing(signf(dx))
	on_hit_flash(Color.RED)

func windup() -> void:
	velocity = Vector2(0, -20)
	if state_timer > 0: return
	if not is_instance_valid(locked_target):
		home = global_position
		state = State.PATROL
		return
	swoop_dir = global_position.direction_to(locked_target.global_position)
	state = State.SWOOP
	state_timer = swoop_time
	swoop_hitbox.activate()
	SFX.play("flyer_swoop")

func swoop() -> void:
	velocity = swoop_dir * swoop_speed
	if state_timer <= 0 or is_on_wall():
		swoop_hitbox.deactivate()
		cooldown_timer = cooldown
		pick_hover_height()
		state = State.HOVER

func update_animation() -> void:
	match state:
		State.PATROL, State.HOVER: play_anim("fly")
		State.WINDUP: play_anim("swoop_windup")
		State.SWOOP: play_anim("swoop")

func hover(delta: float) -> void:
	if not player_in_range:
		home = global_position
		state = State.PATROL
		return
	orbit_time += delta
	var orbit := Vector2(cos(orbit_time * orbit_speed) * hover_distance, -current_hover_height + sin(orbit_time * orbit_speed * 2.0) * bob_height)
	var target := player_target.global_position + orbit
	velocity = ((target - global_position) * 3.0).limit_length(hover_speed)
	var dx := player_target.global_position.x - global_position.x
	if dx != 0: set_facing(signf(dx))
	if cooldown_timer <= 0: start_windup()

func pick_hover_height() -> void:
	current_hover_height = randf_range(hover_height_min, hover_height_max)
