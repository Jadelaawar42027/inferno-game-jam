extends Node

signal sin_absorbed(ability: Ability)
signal floor_changed(new_floor: int)

const TOTAL_SINS := 4
const INTRO_SCENE := "res://scenes/cutscenes/intro.tscn"
const FLOORS := [
	"res://levels/gluttony/rooms/0_gluttony_level.tscn",
	"res://levels/greed/rooms/0_greed_level.tscn",
	"res://levels/violence/rooms/0_violence_level.tscn",
	"res://levels/fraud/rooms/0_fraud_level.tscn",
	"res://levels/treachery/rooms/1_satan_arena.tscn",
]
const ENDING_SCENE := "res://scenes/cutscenes/ending.tscn"
const MENU_SCENE := "res://scenes/ui/mainMenu.tscn"

var fade_rect: ColorRect
var transitioning := false
var checkpoint := Vector2.INF
var current_floor := 1
var abilities: Array[Ability] = []
var sins_absorbed: int:
	get: return abilities.size()
	
var satan_intro_seen := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	layer.add_child(fade_rect)

func absorb(ability: Ability) -> void:
	if ability == null: 
		push_warning("Boss has no reward set") 
		return
	if has_ability(ability.id): return
	abilities.append(ability)
	sin_absorbed.emit(ability)

func has_ability(id: StringName) -> bool:
	return abilities.any(func(a): return a.id == id)

func corruption() -> float:
	return float(sins_absorbed) / TOTAL_SINS

func fade(to: float, time := 0.4) -> void:
	var t := create_tween()
	t.tween_property(fade_rect, "modulate:a", to, time)
	await t.finished
	
func change_to(path: String) -> void:
	if transitioning: return
	transitioning = true
	get_tree().paused = true
	await fade(1.0)
	if path == "": get_tree().reload_current_scene()
	else: get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	MusicManager.play_for_scene(get_tree().current_scene.scene_file_path)
	get_tree().paused = false
	await fade(0.0)
	transitioning = false

func reload_floor() -> void:
	await change_to("")

func start_new_game() -> void:
	reset()
	await change_to(INTRO_SCENE)

func quit_to_menu() -> void:
	reset()
	await change_to(MENU_SCENE)

func start_floor(n: int) -> void:
	if transitioning: return
	current_floor = n
	checkpoint = Vector2.INF
	floor_changed.emit(current_floor)
	await change_to(FLOORS[n - 1])

func go_to_next_floor() -> void:
	if transitioning: return
	if current_floor >= FLOORS.size():
		await change_to(ENDING_SCENE)
		return
	await start_floor(current_floor + 1)

func reset() -> void:
	abilities.clear()
	current_floor = 0
	checkpoint = Vector2.INF
	satan_intro_seen = false
