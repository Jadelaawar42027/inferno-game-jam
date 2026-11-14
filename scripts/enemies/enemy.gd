extends CharacterBody2D
class_name Enemy


@export var flash_time := 0.2
@onready var check_platform: RayCast2D = get_node_or_null("Check_Platform")

var _tween: Tween

@export var walk_speed := 20.0

@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = $Sprite2D

var direction := 1.0
var is_dead := false
var player_target: Player = null
var player_in_range := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.died.connect(die)
	hurtbox.hurt.connect(_on_hurt)

func _on_hurt(_hitbox: Hitbox)->void:
	if is_dead:
		return
	on_hit_flash()
	
func die()->void:
	if is_dead: return
	is_dead = true
	hurtbox.set_deferred("monitorable", false)
	queue_free()

func on_hit_flash(color: Color = Color.WHITE) -> void:
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("flash_color", color)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(func(v: float): mat.set_shader_parameter("flash_amount", v), 1.0, 0.0, flash_time)
	
func apply_gravity(delta: float)->void:
	if not is_on_floor(): velocity += get_gravity() * delta

func set_facing(dir: float) -> void:
	direction = dir
	sprite.flip_h = dir < 0
	if check_platform:
		check_platform.position.x = 7 * dir
		check_platform.force_raycast_update()


func patrol()->void:
	velocity.x = direction * walk_speed
	if is_on_wall(): set_facing(-direction)
	elif check_platform and is_on_floor() and not check_platform.is_colliding(): set_facing(-direction)

func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		player_target = body
		player_in_range = true

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_in_range = false
		player_target = null
