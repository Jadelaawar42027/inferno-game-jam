extends CharacterBody2D
class_name Enemy


@export var flash_time := 0.2
@onready var check_platform: RayCast2D = get_node_or_null("Check_Platform")

var _tween: Tween

@export var walk_speed := 20.0

@export var alert_time := 0.45

var anim_lock := false
var alerted := false


@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1.0
var is_dead := false
var player_target: Player = null
var player_near := false
var player_in_range: bool:
	get: return player_near and player_target != null and not player_target.is_invisible



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.died.connect(die)
	hurtbox.hurt.connect(_on_hurt)
	sprite.animation_finished.connect(_on_anim_finished)

func _on_hurt(_hitbox: Hitbox)->void:
	if is_dead:
		return
	on_hit_flash()
	play_locked("hurt")

func die()->void:
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitorable", false)
	for child in get_children():
		if child is Hitbox: child.deactivate()
	if play_locked("death"): await sprite.animation_finished
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
		player_near = true

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_near = false
		player_target = null
		alerted = false

func play_anim(anim_name: String)->void:
	if anim_lock or is_dead: return
	if sprite.sprite_frames == null: return
	if not sprite.sprite_frames.has_animation(anim_name): return
	if sprite.animation != anim_name: sprite.play(anim_name)

func play_locked(anim_name: String) -> bool:
	if sprite.sprite_frames == null or not sprite.sprite_frames.has_animation(anim_name): return false
	anim_lock = true
	sprite.stop()
	sprite.play(anim_name)
	return true

func _on_anim_finished() -> void:
	if sprite.animation == "death": return
	anim_lock = false
