extends Node

const SFX_ROOT := "res://sound_effects/"
const POOL_SIZE := 16
var sounds: Dictionary = {}
var pool: Array[AudioStreamPlayer] = []
var last_played: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_dir(SFX_ROOT)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		pool.append(p)

func _load_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null: return
	for sub in dir.get_directories():
		_load_dir(path + sub + "/")
	for file in dir.get_files():
		if not file.ends_with(".wav.import"): continue
		file = file.trim_suffix(".import")
		var key := _key_from(file.get_basename())
		if not sounds.has(key): sounds[key] = []
		sounds[key].append(load(path + file))

func _key_from(base: String) -> String:
	var key := base.trim_prefix("sfx_")
	var parts := key.rsplit("_", true, 1)
	if parts.size() == 2 and parts[1].is_valid_int(): key = parts[0]
	return key

func play(key: String, pitch_jitter := 0.05) -> AudioStreamPlayer:
	if not sounds.has(key):
		push_warning("SFX missing: " + key)
		return null
	var now := Time.get_ticks_msec()
	if now - last_played.get(key, -1000) < 50: return null
	last_played[key] = now
	var p := _free_player()
	p.stream = sounds[key].pick_random()
	p.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	p.play()
	return p

func _free_player() -> AudioStreamPlayer:
	for p in pool:
		if not p.playing: return p
	return pool[0]
