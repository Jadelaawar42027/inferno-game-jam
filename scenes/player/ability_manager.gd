extends Node

class_name AbilityManager

@onready var player := owner as Player

var active: Dictionary[StringName, AbilityBehavior] = {}

func _ready() -> void:
	await player.ready
	GameState.sin_absorbed.connect(_on_sin_absorbed)
	for a in GameState.abilities: _add_behavior(a)

func _on_sin_absorbed(ability: Ability)->void:
	_add_behavior(ability)
	player.play_absorb_animation()

func _add_behavior(ability: Ability)->void:
	if ability.behavior == null or active.has(ability.id): return
	var b := ability.behavior.instantiate() as AbilityBehavior
	if b == null:
		push_error("Behavior scene root must extend AbilityBehavior: " + ability.id)
		return
	b.player = player
	b.ability = ability
	add_child(b)
	active[ability.id] = b
	b.on_added()

func physics_update(delta: float) -> void:
	for b in active.values(): b.physics_update(delta)

func get_behavior(id: StringName) -> AbilityBehavior:
	return active.get(id)
