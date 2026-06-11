extends Node

@onready var beep_player    = $BeepPlayer
@onready var click_player   = $ClickPlayer
@onready var menu_bgm       = $MenuBGMPlayer
@onready var memorize_bgm   = $MemorizeBGMPlayer
@onready var defuse_bgm     = $DefuseBGMPlayer
@onready var win_bgm        = $WinBGMPlayer
@onready var fail_bgm       = $FailBGMPlayer

func _stop_bgm() -> void:
	menu_bgm.stop()
	memorize_bgm.stop()
	defuse_bgm.stop()
	win_bgm.stop()
	fail_bgm.stop()

func play_beep() -> void:
	beep_player.stop()
	beep_player.play()
func play_click() -> void:
	click_player.stop()
	click_player.play()

func play_menu_bgm() -> void:
	_stop_bgm()
	menu_bgm.play()
func play_memorize_bgm() -> void:
	_stop_bgm()
	memorize_bgm.play()
func play_defuse_bgm() -> void:
	_stop_bgm()
	defuse_bgm.play()
func play_win_bgm() -> void:
	_stop_bgm()
	win_bgm.play()
func play_fail_bgm() -> void:
	_stop_bgm()
	fail_bgm.play()
