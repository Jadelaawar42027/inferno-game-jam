extends Area2D

@export var boss: Boss
@onready var barrier_shape: CollisionShape2D = $Barrier/CollisionShape2D
@onready var seal: CanvasItem = $Seal

var open := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if boss == null or (boss.reward and GameState.has_ability(boss.reward.id)):
		set_open(true, true)
	else:
		boss.boss_defeated.connect(func(): set_open(true, false))

func set_open(value: bool, instant: bool) -> void:
	open = value
	barrier_shape.set_deferred("disabled", value)
	if instant: seal.modulate.a = 0.0 if value else 1.0
	else: create_tween().tween_property(seal, "modulate:a", 0.0 if value else 1.0, 0.8)

func _on_body_entered(body: Node2D) -> void:
	if not open or not body is Player: return
	set_deferred("monitoring", false)
	GameState.go_to_next_floor()
