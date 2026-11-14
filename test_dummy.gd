extends StaticBody2D

@onready var body: ColorRect = $Body
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var contact: Hitbox = $ContactHitbox
@onready var health: HealthComponent = $health_component

const BASE_COLOR := Color.RED

func _on_hurt():
	body.color = Color.WHITE
	var tween := create_tween()
	tween.tween_property(body, "color", BASE_COLOR, 0.12)
	print("dummy hp: ", health.current_health)

func _on_died():
	hide()
	hurtbox.set_deferred("monitorable", false)
	contact.deactivate()
	await get_tree().create_timer(2.0).timeout
	health.reset()
	show()
	hurtbox.set_deferred("monitorable", true)
	contact.activate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
