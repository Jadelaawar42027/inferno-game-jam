extends Node

signal sin_absorbed(ability: Ability)
signal floor_changed(new_floor: int)

const TOTAL_SINS := 4

var current_floor := 1
var abilities: Array[Ability] = []
var sins_absorbed: int:
	get: return abilities.size()
	

func absorb(ability: Ability) -> void:
	if ability == null: 
		push_warning("Boss has no reward set") 
		return
	if has_ability(ability.id): return
	abilities.append(ability)
	sin_absorbed.emit(ability)

func has_ability(id: StringName) -> bool:
	return abilities.any(func(a): return a.id == id)

func corruption() -> float:
	return float(sins_absorbed) / TOTAL_SINS

func advance_floor() -> void:
	current_floor += 1
	floor_changed.emit(current_floor)

func reset() -> void:
	abilities.clear()
	current_floor = 1
