extends AbilityBehavior

class_name ChargeAttackBehavior

@export var min_charge := 0.5
@export var max_charge := 3.0
@export var max_damage := 4
@export var move_slow := 0.4

var hold := 0.0
var charging := false
var base_damage := 1

var charge_sfx: AudioStreamPlayer

func physics_update(delta: float) -> void:
	if player.hurt_lock_timer > 0: 
		if charge_sfx: charge_sfx.stop()
		hold = 0.0
		charging = false
		return
	if Input.is_action_pressed("attack"): 
		hold += delta
		if hold >= min_charge and not charging and player.active_hitbox == null: 
			charging = true
			player.play_action("heavy_charge")
			charge_sfx = SFX.play("charge")
		if charging: player.velocity.x *= move_slow
	elif charging: release()
	else: hold = 0.0

func release() -> void:
	if charge_sfx: charge_sfx.stop()
	SFX.play("charge_release")
	var ratio := clampf((hold - min_charge) / (max_charge - min_charge), 0.0, 1.0)
	hold = 0.0
	charging = false
	player.side_slash.damage = 2 + int(ratio * (max_damage - 2))
	player.side_slash.position.x = player.facing * 19
	player.active_hitbox = player.side_slash
	player.side_slash.activate()
	player.attack_active_timer = 0.2
	player.attack_cooldown_timer = player.attack_cooldown
	player.play_action("heavy_slash")
	player.shake(4.0)
	await player.get_tree().create_timer(0.25).timeout
	player.side_slash.damage = base_damage

func on_added() -> void:
	base_damage = player.side_slash.damage
