extends "res://scripts/enemies/enemyFlying.gd"

var transformed := false
var transforming := false

func _physics_process(delta: float) -> void:
	if transforming: 
		velocity = Vector2.ZERO
		return
	if not transformed and player_in_range: 
		start_transform()
		return
	else:
		super(delta)

func start_transform() -> void:
	transforming = true
	velocity = Vector2.ZERO
	var dx := player_target.global_position.x - global_position.x
	if dx != 0: set_facing(signf(dx))
	sprite.play("transform")
	await sprite.animation_finished
	transforming = false
	transformed = true
	cooldown_timer = 0.5

func update_animation()->void:
	if not transformed:
		play_anim("fly_calm")
		return
	super()
	
