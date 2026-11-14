extends Enemy


enum State { PATROL, CHASE, LUNGE }
var state := State.PATROL

@export var chase_speed := 50.0
@export var lunge_range := 20.0
@export var lunge_speed := 100.0
@export var windup_time := 0.3
@export var lunge_time := 0.3
@export var cooldown := 5.0

var cooldown_timer := 0.0
var windup_timer := 0.0
var lunge_timer := 0.0
var lunge_dir := 1.0
var lunge_started := false

@onready var lunge_hitbox: Hitbox = $LungeHitbox


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	cooldown_timer -= delta
	if not player_in_range and state != State.LUNGE: state = State.PATROL
	if player_in_range:
		var dx := player_target.global_position.x - global_position.x
		if state == State.PATROL and signf(dx) == direction: state = State.CHASE
		if state == State.CHASE and absf(dx) < lunge_range and cooldown_timer <= 0: start_lunge()
	match state:
		State.PATROL: patrol()
		State.CHASE: chase()
		State.LUNGE: lunge(delta)
	
	update_animation()
	move_and_slide()

func set_facing(dir: float)-> void:
	super(dir)
	lunge_hitbox.position.x = 10 * dir

func chase()->void:
	var dir := signf(player_target.global_position.x - global_position.x)
	if dir != 0: set_facing(dir)
	if check_platform.is_colliding(): velocity.x = direction * chase_speed
	else: velocity.x = 0

func start_lunge()->void:
	state = State.LUNGE
	windup_timer = windup_time
	lunge_timer = lunge_time
	lunge_dir = direction
	lunge_started = false
	on_hit_flash(Color.RED)

func lunge(delta: float)->void:
	velocity.x = 0
	if windup_timer > 0:
		windup_timer -= delta
		return
	if not lunge_started:
		lunge_started = true
		lunge_hitbox.activate()
	velocity.x = lunge_dir * lunge_speed
	lunge_timer -= delta
	if lunge_timer <= 0: end_lunge()

func end_lunge()->void:
	lunge_hitbox.deactivate()
	cooldown_timer = cooldown
	state = State.CHASE

func update_animation()-> void:
	match state:
		State.PATROL: play_anim("walk")
		State.CHASE: play_anim("run")
		State.LUNGE: play_anim("windup" if windup_timer > 0 else "lunge")
