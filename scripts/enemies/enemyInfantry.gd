extends Enemy



#States the enemy can be in
enum STATES{PATROL, CHASE, LUNGE}
var CURRENTSTATE = STATES.PATROL

#Walk vars
var SPEED_WALK = 20
var PATROL_RANGE = 10 

#Chase vars
var SPEED_CHASE = 30
var CHASE_RANGE = 10


#Lunge vars 
var RANGE_LUNGE
var WINDUP_TIME
var LUNGE_TIME
var COOLDOWN


#Enemy patrol

#Enemy chase

#Melee lunge
