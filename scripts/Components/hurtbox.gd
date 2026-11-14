extends Area2D

class_name Hurtbox

signal hurt(hitbox: Hitbox)

@export var health : HealthComponent

var invulnerable := false

func receive_hit(hitbox: Hitbox)-> bool:
	if invulnerable:
		return false
	health.take_damage(hitbox.damage)
	hurt.emit(hitbox)
	return true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
