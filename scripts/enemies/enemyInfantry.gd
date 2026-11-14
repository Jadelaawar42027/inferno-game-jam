extends Enemy



#States the enemy can be in
enum STATES{PATROL, CHASE, LUNGE}
var CURRENTSTATE = STATES.PATROL

#Walk vars
var SPEED_WALK = 20
var PATROL_RANGE = 10 
var DIRECTION = 1

#Chase vars
var SPEED_CHASE = 50
var CHASE_RANGE = 10


#Lunge vars 
var RANGE_LUNGE
var WINDUP_TIME
var LUNGE_TIME
var COOLDOWN

#Signal functions
var BODY_ENTERED = false
var PLAYER_SEEN = false
var PLAYER_TARGET

#baseline movement function that will reach out to others

func _physics_process(delta: float) -> void:
	if BODY_ENTERED == true:
		if signf(PLAYER_TARGET.global_position.x - self.global_position.x ) == DIRECTION:
			CURRENTSTATE = STATES.CHASE
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
	if $Check_Platform.is_colliding():
		if is_on_floor():
			velocity.x = SPEED_CHASE * signf(PLAYER_TARGET.global_position.x - self.global_position.x )
			$Sprite2D.flip_h = signf(PLAYER_TARGET.global_position.x - self.global_position.x )
			DIRECTION = signf(PLAYER_TARGET.global_position.x - self.global_position.x )
			$Check_Platform.position.x = 7 * signf(PLAYER_TARGET.global_position.x - self.global_position.x )
	elif not $Check_Platform.is_colliding():
		velocity.x = 0
		
	


#Melee lunge
func _enemyInfantry_lunge(delta):
	#Check if player is close
	#Flashes before lunges
	#Does damage to player
	pass


func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		BODY_ENTERED = true
		PLAYER_TARGET = body


func _on_detection_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		BODY_ENTERED = false
	CURRENTSTATE = STATES.PATROL
