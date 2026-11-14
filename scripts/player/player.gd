extends CharacterBody2D

class_name Player

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

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var facing := 1

func _physics_process(delta: float) -> void:
	
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
		
	var direction = signf(Input.get_axis("move_left", "move_right"))
	velocity.x = run_speed * direction
	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
	
	move_and_slide()
	
	if direction != 0:
		facing = int(direction)
		visual.scale.x = facing
