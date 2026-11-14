extends Enemy



#States the enemy can be in
enum STATES{PATROL, CHASE, LUNGE}
var CURRENTSTATE = STATES.PATROL

#Walk vars
var SPEED_WALK = 20
var PATROL_RANGE = 10 
var DIRECTION = 1

#Chase vars
var SPEED_CHASE = 30
var CHASE_RANGE = 10


#Lunge vars 
var RANGE_LUNGE
var WINDUP_TIME
var LUNGE_TIME
var COOLDOWN

#baseline movement function that will reach out to others

func _physics_process(delta: float) -> void:
	if CURRENTSTATE == STATES.PATROL:
		_enemyInfantry_patrol(delta)
	elif CURRENTSTATE == STATES.CHASE:
		_enemyInfantry_chase(delta)
	elif CURRENTSTATE == STATES.LUNGE:
		_enemyInfantry_lunge(delta)
	super(delta)

#Enemy patrol
func _enemyInfantry_patrol(delta):
	velocity.x = SPEED_WALK * DIRECTION
	if not $Check_Platform.is_colliding():
		if is_on_floor():
			DIRECTION = DIRECTION * -1
			
			#Flips the asset and raycast
			$Sprite2D.flip_h = DIRECTION == -1
			$Check_Platform.position.x = 7 * DIRECTION
			
	
#Enemy chase
func _enemyInfantry_chase(delta):
	pass

#Melee lunge
func _enemyInfantry_lunge(delta):
	pass
