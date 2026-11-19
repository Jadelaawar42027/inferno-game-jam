extends AbilityBehavior

class_name InvisibilityBehavior

@export var duration := 3.0
@export var cooldown := 8.0
@export var alpha := 0.35

var timer := 0.0
var cooldown_timer := 0.0

func physics_update(delta: float) -> void:
	cooldown_timer -= delta
	if timer > 0: 
		timer -= delta 
		if timer <= 0: end()
	if Input.is_action_just_pressed("invisibility") and timer <= 0 and cooldown_timer <= 0: start()

func start() -> void:
	timer = duration
	player.is_invisible = true
	player.visual.modulate.a = alpha
	SFX.play("invis_on")

func end() -> void:
	player.is_invisible = false
	player.visual.modulate.a = 1.0
	cooldown_timer = cooldown
	SFX.play("invis_off")
