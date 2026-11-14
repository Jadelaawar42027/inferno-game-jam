extends CharacterBody2D
class_name Enemy

#Signals
signal HEALTH_DEPLETED

#EXPORT var 
@export var MAX_HEALTH: int = 10
@export var MEDIUM_ATTACK: int = 1
var MOVEMENT: float = 10.0
@export var TURN_SPEED: float = 10.0
@export var FLASH_HIT: float = 0.2


#EXPORT variables to possibly be removed later
@export var PLAYER_DAMAGE: int = 1

var HEALTH: int
var DEAD: bool = false
var _tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HEALTH = MAX_HEALTH
	
	
func die():
	DEAD = true
	HEALTH_DEPLETED.emit()
	queue_free()

func on_hit_flash(color: Color = Color.WHITE) -> void:
	var mat := $Sprite2D.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("flash_color", color)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(func(v): mat.set_shader_parameter("flash_amount", v), 1.0, 0.0, FLASH_HIT)
	
#
#Signal functions
#

#Sig of damage taken
func take_damage(amount):
	#Could cause frame issues if statement is not below
	if DEAD == true:
		return
	on_hit_flash()
	HEALTH -= amount
	if HEALTH <= 0:
		die()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		take_damage(PLAYER_DAMAGE)
				
#Gravity func taken from https://www.youtube.com/watch?v=kHki30-DxRQ&t=16s
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
