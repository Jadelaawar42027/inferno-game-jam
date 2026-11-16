extends Node2D

@export var ability: Ability
@onready var title: Label = $Title
@onready var hint: Label = $Hint

func _ready() -> void:
	modulate.a = 0.0
	if ability == null: return
	title.text = ability.display_name.to_upper()
	hint.text = ability.description.replace("{key}", key_name(ability.action))
	if GameState.has_ability(ability.id):
		modulate.a = 1.0
		return
	await get_tree().process_frame
	var p := get_tree().get_first_node_in_group("player") as Player
	if p: p.absorb_finished.connect(_on_absorb_finished)

func _on_absorb_finished(a: Ability) -> void:
	if a.id != ability.id: return
	var p := get_tree().get_first_node_in_group("player") as Player
	if p: global_position = p.global_position + Vector2(0, -60)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 1.2)

func key_name(action: StringName) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			var code: Key = e.physical_keycode if e.physical_keycode != 0 else e.keycode
			return OS.get_keycode_string(code)
	return String(action).to_upper()
