extends Node2D

class_name Coin

var direction := 1
var speed := 260.0

@export var lifetime := 1.2
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var ray: RayCast2D = $Ray

func _ready() -> void:
	sprite.play("coin")
	ray.target_position = Vector2(6 * direction, 0)
	hitbox.activate()
	hitbox.hit_landed.connect(_on_hit)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	if ray.is_colliding(): queue_free()

func _on_hit(_h) -> void:
	SFX.play("coin_hit")
	queue_free()
