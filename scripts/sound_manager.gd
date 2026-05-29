# sound_manager.gd
extends Node

# preload all sounds here — one place, easy to swap
const SOUNDS = {
	"ocean":    preload("res://audio/fishing-bgm.wav"),
	"reel":     preload("res://audio/tossing-rod.mp3"),
	"click":    preload("res://audio/option-click.mp3"),
	"blackout": preload("res://audio/lady-blackout.wav"),
	"bar-success": preload("res://audio/fishbar-succeed.wav"),
	"bar-fail": preload("res://audio/fishbar-fail.wav"),
	#"leaves":   preload("res://audio/leaves.ogg"),
	#"freed":    preload("res://audio/soul_freed.ogg"),
}

var music: AudioStreamPlayer
var sfx_channels: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# create music player
	music = AudioStreamPlayer.new()
	add_child(music)
	
	# create 3 sfx channels
	for i in range(3):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_channels.append(p)

func play_music(key: String) -> void:
	if not SOUNDS.has(key):
		return
	music.stream = SOUNDS[key]
	music.play()

func stop_music() -> void:
	music.stop()

func play_sfx(key: String) -> void:
	if not SOUNDS.has(key):
		return
	for player in sfx_channels:
		if not player.playing:
			player.stream = SOUNDS[key]
			player.play()
			return

	sfx_channels[0].stream = SOUNDS[key]
	sfx_channels[0].play()

func stop_sfx() -> void:
	for player in sfx_channels:
		player.stop()

func duck_music() -> void:
	# lower volume during dialogue/reeling, don't stop
	var t = create_tween()
	t.tween_property(music, "volume_db", -10.0, 0.5)

func unduck_music() -> void:
	# restore volume when returning to idle
	var t = create_tween()
	t.tween_property(music, "volume_db", 0.0, 0.8)
