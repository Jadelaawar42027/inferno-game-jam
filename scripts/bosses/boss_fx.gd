extends Node2D

class_name BossFx

const SIZES := {"shockwave": Vector2(24, 16), "fire": Vector2(22, 24), "meatball": Vector2(14, 14), "rock": Vector2(16, 16), "venom": Vector2(10, 10), "puddle": Vector2(30, 5), "pillar_rise": Vector2(22, 60), "coin": Vector2(8, 8)}
const GROUND := ["shockwave", "fire", "puddle", "pillar_rise", "warning"]
const LIFE := {"shockwave": 0.9, "fire": 2.0, "warning": 0.6, "puddle": 4.0}

var anim_name := "meatball"
var velocity := Vector2.ZERO
var gravity := 0.0
var land_anim := ""
var harmless_on_land := false
var land_sfx := ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var ray: RayCast2D = $Ray


func _ready() -> void:
	sprite.play(anim_name)
	sprite.flip_h = velocity.x < 0
	var size: Vector2 = SIZES.get(anim_name, Vector2.ZERO)
	if size == Vector2.ZERO: hitbox.deactivate()
	else: (hit_shape.shape as RectangleShape2D).size = size
	if anim_name in GROUND: hitbox.position.y = -size.y / 2
	if LIFE.has(anim_name): get_tree().create_timer(LIFE[anim_name], false).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
	if gravity > 0 and velocity.y > 0 and ray.is_colliding(): land()

func land() -> void:
	gravity = 0.0
	velocity = Vector2.ZERO
	if land_sfx != "": SFX.play(land_sfx)
	if SIZES.has(land_anim):
		(hit_shape.shape as RectangleShape2D).size = SIZES[land_anim]
		hitbox.position.y = -SIZES[land_anim].y / 2 if land_anim in GROUND else 0.0
	if LIFE.has(land_anim): get_tree().create_timer(LIFE[land_anim], false).timeout.connect(queue_free)
	if harmless_on_land: hitbox.deactivate()
	if land_anim == "":
		queue_free()
		return
	sprite.play(land_anim)
	if not sprite.sprite_frames.get_animation_loop(land_anim):
		await sprite.animation_finished
		queue_free()
