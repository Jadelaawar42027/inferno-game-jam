extends AbilityBehavior

class_name GoldThrowBehavior

@export var coin_scene: PackedScene
@export var max_ammo := 5
@export var cooldown := 0.4

var ammo := 0
var cooldown_timer := 0.0

func on_added() -> void:
	ammo = max_ammo

func physics_update(delta: float) -> void:
	cooldown_timer -= delta
	if Input.is_action_just_pressed("throw") and ammo > 0 and cooldown_timer <= 0 and player.hurt_lock_timer <= 0 and not player.action_lock: throw()
	elif Input.is_action_just_pressed("throw") and ammo <= 0: SFX.play("coin_empty")

func throw() -> void:
	ammo -= 1
	cooldown_timer = cooldown
	player.play_action("throw")
	await player.get_tree().create_timer(0.14).timeout
	var coin := coin_scene.instantiate() as Coin
	coin.direction = player.facing
	player.get_parent().add_child(coin)
	SFX.play("coin_throw")
	coin.global_position = player.global_position + Vector2(player.facing * 10, -12)
