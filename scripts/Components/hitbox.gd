extends Area2D

class_name Hitbox

@onready var shape: CollisionShape2D = $CollisionShape2D

@export var damage := 1
@export var knowckback_force := 150.0
@export var pogo_allowed := false
@export var persistent := false

signal hit_landed(hurtbox: Hurtbox)

var active := false
var already_hit : Array[Hurtbox] = []

func activate():
	already_hit.clear()
	active = true
	shape.set_deferred("disabled", false)

func deactivate():
	active = false
	shape.set_deferred("disabled", true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if persistent:
		activate()

func _physics_process(_delta: float) -> void:
	if not active:
		return
	for area in get_overlapping_areas():
		if not area is Hurtbox: continue
		if already_hit.has(area): continue
		if area.receive_hit(self):
			if not persistent:
				already_hit.append(area)
				hit_landed.emit(area)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
