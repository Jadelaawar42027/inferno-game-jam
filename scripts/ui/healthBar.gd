extends Control

class_name HealthBar


@export var HEALTH : HealthComponent

@onready var BAR: ProgressBar = $PanelContainer/Bar


#I set the variables here to match the vars in HealthComponent
func health_bar_update(current_health, max_health):
	BAR.max_value = max_health
	BAR.value = current_health


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if HEALTH == null:
		push_warning("Health is null")
		return
	BAR.max_value = HEALTH.max_health
	BAR.value = HEALTH.current_health
	HEALTH.health_changed.connect(health_bar_update)
