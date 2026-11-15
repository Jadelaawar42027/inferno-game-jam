extends AbilityBehavior

class_name DashBehavior

@export var dash_speed := 420.0
@export var dash_time := 0.18
@export var cooldown := 0.5

var timer := 0.0
var cooldown_timer := 0.0
var dir := 1
var air_dash_used := false

func physics_update(delta: float) -> void:
	cooldown_timer -= delta
	if player.is_on_floor(): air_dash_used = false
	if timer > 0 and player.hurt_lock_timer > 0: timer = 0.0 
	if timer > 0: 
		timer -= delta 
		player.velocity = Vector2(dir * dash_speed, 0) 
		return
	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0 and player.hurt_lock_timer <= 0 and not air_dash_used: start_dash()

func start_dash() -> void:
	dir = player.facing
	timer = dash_time
	cooldown_timer = cooldown
	if not player.is_on_floor(): air_dash_used = true
	player.end_attack()
	player.play_action("dash")
