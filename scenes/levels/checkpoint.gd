extends Area2D

@onready var spawn: Marker2D = $SpawnPoint
@onready var sprite: Sprite2D = $Sprite2D

var active := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if GameState.checkpoint == spawn.global_position: set_active()

func _on_body_entered(body: Node2D) -> void:
	if active or not body is Player: return
	GameState.checkpoint = spawn.global_position
	SFX.play("checkpoint")
	set_active()

func set_active() -> void:
	active = true
	sprite.modulate = Color(1.0, 0.6, 0.3)
