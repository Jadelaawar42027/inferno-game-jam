extends Enemy

enum State { PATROL, CHARGE, SLAM }
var state := State.PATROL

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	match state:
		State.PATROL: patrol()
		State.CHARGE: charge(delta)
		State.SLAM: slam(delta)
	move_and_slide()


func charge(_delta: float)->void:
	pass

func slam(_delta: float)-> void:
	pass
