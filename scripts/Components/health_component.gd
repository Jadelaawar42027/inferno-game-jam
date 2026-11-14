extends Node

class_name HealthComponent

@export var max_health :int

var current_health := 0

# Signals
signal health_changed(current_health, max_health)
signal damaged(amount)
signal died

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		died.emit()
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)

func heal(amount):
	current_health += amount
	if current_health >= max_health:
		current_health = max_health
	health_changed.emit(current_health, max_health)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func reset()->void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
