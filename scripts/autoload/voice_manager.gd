extends Node

const VOICE_DIR := "res://assets/audio/voice/"
var voice_player: AudioStreamPlayer
var boss_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	voice_player = AudioStreamPlayer.new()
	add_child(voice_player)
	boss_player = AudioStreamPlayer.new()
	add_child(boss_player)

func play_line(id: String, bus := "Voice", pitch := 1.0, interrupt := true) -> void:
	var path := VOICE_DIR + id + ".ogg"
	if not ResourceLoader.exists(path): return
	var p := voice_player if bus == "Voice" else boss_player
	if not interrupt and p.playing: return
	if bus == "Voice": update_corruption()
	p.bus = bus
	p.stream = load(path)
	p.pitch_scale = pitch
	p.play()

func update_corruption() -> void:
	var idx := AudioServer.get_bus_index("Voice")
	var c := GameState.corruption()
	var shift := AudioServer.get_bus_effect(idx, 0) as AudioEffectPitchShift
	shift.pitch_scale = lerpf(1.0, 0.75, c)
	var dist := AudioServer.get_bus_effect(idx, 1) as AudioEffectDistortion
	dist.drive = lerpf(0.0, 0.5, c)

func is_talking() -> bool:
	return voice_player.playing
