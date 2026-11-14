extends Boss


func get_attacks() -> Array[String]:
	return ["dash"]

func do_attack(attack_name: String) -> void:
	match attack_name:
		"dash": await attack_dash()

func attack_dash() -> void:
	face_player()
	on_hit_flash(Color.RED)
	await wait(0.5)
	if is_dead: return
	velocity.x = direction * 150
	await wait(0.4)
	velocity.x = 0

func on_phase_entered(new_phase: int) -> void:
	print("PHASE ", new_phase)
