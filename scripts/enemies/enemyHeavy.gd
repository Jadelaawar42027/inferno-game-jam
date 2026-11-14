extends Enemy

enum State { PATROL, CHARGE_WINDUP, CHARGE, SLAM_WINDUP, SLAM, RECOVER }
var state := State.PATROL

@export var charge_speed := 120.0
@export var charge_windup_time := 0.6
@export var charge_time := 0.8
@export var slam_range := 28.0
@export var slam_windup_time := 0.7
@export var slam_active_time := 0.15
@export var recover_time := 1.0
@export var cooldown := 2.0

var state_timer := 0.0
var cooldown_timer := 0.0

@onready var charge_hitbox: Hitbox = $ChargeHitbox
@onready var slam_hitbox: Hitbox = $SlamHitbox

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	cooldown_timer -= delta
	state_timer -= delta
	match state:
		State.PATROL: heavy_patrol()
		State.CHARGE_WINDUP: charge_windup()
		State.CHARGE: charge()
		State.SLAM_WINDUP: slam_windup()
		State.SLAM: slam()
		State.RECOVER: recover()
	update_animation()
	move_and_slide()

func set_facing(dir: float) -> void:
	super(dir)
	charge_hitbox.position.x = 10 * dir
	slam_hitbox.position.x = 18 * dir

func player_dx() -> float:
	return player_target.global_position.x - global_position.x

func heavy_patrol() -> void:
	patrol()
	if not player_in_range or cooldown_timer > 0: return
	if absf(player_dx()) < slam_range: start_slam()
	elif signf(player_dx()) == direction: start_charge()

func start_charge() -> void:
	state = State.CHARGE_WINDUP
	state_timer = charge_windup_time
	velocity.x = 0
	on_hit_flash(Color.RED)

func charge_windup() -> void:
	velocity.x = 0
	if state_timer > 0: return
	state = State.CHARGE
	state_timer = charge_time
	charge_hitbox.activate()

func charge() -> void:
	velocity.x = direction * charge_speed
	var hit_edge := is_on_wall() or not check_platform.is_colliding()
	var close := player_in_range and absf(player_dx()) < slam_range
	if hit_edge or close or state_timer <= 0:
		charge_hitbox.deactivate()
		velocity.x = 0
		if close: start_slam()
		else: start_recover()

func start_slam() -> void:
	if player_in_range and player_dx() != 0: set_facing(signf(player_dx()))
	state = State.SLAM_WINDUP
	state_timer = slam_windup_time
	velocity.x = 0
	on_hit_flash(Color.RED)

func slam_windup() -> void:
	velocity.x = 0
	if state_timer > 0: return
	state = State.SLAM
	state_timer = slam_active_time
	slam_hitbox.activate()

func slam() -> void:
	velocity.x = 0
	if state_timer > 0: return
	slam_hitbox.deactivate()
	start_recover()

func start_recover() -> void:
	state = State.RECOVER
	state_timer = recover_time
	cooldown_timer = cooldown

func recover() -> void:
	velocity.x = 0
	if state_timer <= 0: state = State.PATROL

func update_animation() -> void:
	match state:
		State.PATROL: play_anim("walk")
		State.CHARGE_WINDUP: play_anim("charge_windup")
		State.CHARGE: play_anim("charge")
		State.SLAM_WINDUP: play_anim("slam_windup")
		State.SLAM: play_anim("slam")
		State.RECOVER: play_anim("recover")
