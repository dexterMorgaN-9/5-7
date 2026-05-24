extends Node

@onready var beep_player    = $BeepPlayer
@onready var defuse_player  = $DefusePlayer
@onready var explode_player = $ExplosionPlayer
@onready var bgm_player    = $BGMPlayer

func play_beep() -> void:
	beep_player.stop()
	beep_player.play()

func play_defuse() -> void:
	bgm_player.stop()
	defuse_player.play()

func play_explosion() -> void:
	bgm_player.stop()
	explode_player.play()

func play_bgm() -> void:
	if !bgm_player.playing:
		bgm_player.play()
