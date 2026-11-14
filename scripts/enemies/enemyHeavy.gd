extends Enemy


#State machine of different stances the enemy can have
enum STATES{PATROL, CHARGE, SLAM}
var CURRENTSTATE = STATES.PATROL

#Walk vars
@export var SPEED_WALK = 10
var PATROL_RANGE = 10 
var DIRECTION = 1


#Charge Vars


#Slam vars

#Same loop
func _physics_process(delta: float) -> void:
	
	#Changes enemy behavior
	if CURRENTSTATE == STATES.PATROL:
		_enemyHeavy_patrol(delta)
	elif CURRENTSTATE == STATES.CHARGE:
		_enemyHeavy_charge(delta)
	elif CURRENTSTATE == STATES.SLAM:
		_enemyHeavy_slam(delta)
	super(delta)

#Patrol will be the same as the other
#probably should have this be a function that is called
func _enemyHeavy_patrol(delta):
	velocity.x = SPEED_WALK * DIRECTION
	if not $Check_Platform.is_colliding():
		if is_on_floor():
			DIRECTION = DIRECTION * -1
			#Flips the asset and raycast
			$Sprite2D.flip_h = DIRECTION == -1
			$Check_Platform.position.x = 7 * DIRECTION
			


#Charge would be like chase
func _enemyHeavy_charge(delta):
	pass

#Slam is slow and will have massive attack
func _enemyHeavy_slam(delta):
	pass
		
