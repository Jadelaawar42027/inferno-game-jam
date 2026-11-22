extends Node

const TRACKS := {
	"awakening": preload("res://assets/audio/music/awakening.ogg"),
	"gluttony_level": preload("res://assets/audio/music/gluttony_level.ogg"),
	"gluttony_boss": preload("res://assets/audio/music/gluttony_boss.ogg"),
	"greed_level": preload("res://assets/audio/music/greed_level.ogg"),
	"greed_boss": preload("res://assets/audio/music/greed_boss.ogg"),
	"violence_level": preload("res://assets/audio/music/violence_level.ogg"),
	"violence_boss": preload("res://assets/audio/music/violence_boss.ogg"),
	"fraud_level": preload("res://assets/audio/music/fraud_level.ogg"),
	"fraud_boss": preload("res://assets/audio/music/fraud_boss.ogg"),
	"satan_boss": preload("res://assets/audio/music/satan_boss.ogg"),
	"satan_halls": preload("res://assets/audio/music/satan_halls.ogg"),
	"final_poem": preload("res://assets/audio/music/final_poem.ogg"),
}
const FLOOR_TRACKS := {
	"res://levels/gluttony/rooms/0_gluttony_level.tscn": "gluttony_level",
	"res://levels/greed/rooms/0_greed_level.tscn": "greed_level",
	"res://levels/violence/rooms/0_violence_level.tscn": "violence_level",
	"res://levels/fraud/rooms/0_fraud_level.tscn": "fraud_level",
	"res://levels/treachery/rooms/1_satan_arena.tscn": "satan_halls",
}

var a: AudioStreamPlayer
var b: AudioStreamPlayer
var current: AudioStreamPlayer
var current_key := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	a = AudioStreamPlayer.new()
	a.bus = "Music"
	add_child(a)
	b = AudioStreamPlayer.new()
	b.bus = "Music"
	add_child(b)
	current = a


func play(key: String, fade := 1.0) -> void:
	if key == current_key: return
	current_key = key
	var next := b if current == a else a
	next.stream = TRACKS[key]
	next.volume_db = -40.0
	next.play()
	var t := create_tween().set_parallel()
	t.tween_property(next, "volume_db", 0.0, fade)
	t.tween_property(current, "volume_db", -40.0, fade)
	await t.finished
	current.stop()
	current = next

func play_for_scene(path: String) -> void:
	if FLOOR_TRACKS.has(path): play(FLOOR_TRACKS[path])
