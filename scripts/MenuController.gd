extends Control

@onready var settings_panel = $SettingsPanel
@onready var nameinput = $SettingsPanel/NameInput
@onready var volslider = $SettingsPanel/VolumeSlider
@onready var audio     = $AudioManager

const SAVE_PATH = "user://settings.cfg"
const GH_URL    = "https://github.com/dexterMorgaN-9/5-7/blob/main/README.md"

var volbus = "Master"
var cfg_loaded = false


func _load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		nameinput.text = cfg.get_value("player", "name", "Rookie")
		var vol = cfg.get_value("audio", "volume", 0.8)
		volslider.value = vol
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(volbus), linear_to_db(vol))
		cfg_loaded = true
	else:
		nameinput.text = "Rookie"
		volslider.value = 0.8

func _save_settings() -> void:
	var cfg = ConfigFile.new()
	var pname = nameinput.text.strip_edges()
	if pname.is_empty(): pname = "Rookie"
	cfg.set_value("player", "name", pname)
	cfg.set_value("audio", "volume", volslider.value)
	cfg.save(SAVE_PATH)

func _apply_styles() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0, 1, 0.25, 0.6)
	$SettingsPanel.add_theme_stylebox_override("panel", style)

	var bn = StyleBoxFlat.new()
	bn.bg_color = Color(0,0,0,0)
	bn.border_width_left = 0; bn.border_width_right = 0
	bn.border_width_top = 0; bn.border_width_bottom = 0

	var bh = StyleBoxFlat.new()
	bh.bg_color = Color(0, 1, 0.25, 0.15)
	bh.border_width_left = 1; bh.border_width_right = 1
	bh.border_width_top = 1; bh.border_width_bottom = 1
	bh.border_color = Color(0, 1, 0.25, 0.5)
	bh.corner_radius_top_left = 4; bh.corner_radius_top_right = 4
	bh.corner_radius_bottom_left = 4; bh.corner_radius_bottom_right = 4

	var bp = StyleBoxFlat.new()
	bp.bg_color = Color(0, 1, 0.25, 0.3)
	bp.border_width_left = 1; bp.border_width_right = 1
	bp.border_width_top = 1; bp.border_width_bottom = 1
	bp.border_color = Color(0, 1, 0.25, 1.0)
	bp.corner_radius_top_left = 4; bp.corner_radius_top_right = 4
	bp.corner_radius_bottom_left = 4; bp.corner_radius_bottom_right = 4

	var bb = $SettingsPanel/BackButton
	bb.add_theme_stylebox_override("normal",  bn)
	bb.add_theme_stylebox_override("hover",   bh)
	bb.add_theme_stylebox_override("pressed", bp)
	bb.add_theme_stylebox_override("focus",   bn)
	bb.add_theme_color_override("font_color",       Color(0, 1, 0.25, 1))
	bb.add_theme_color_override("font_hover_color",  Color(0, 1, 0.25, 1))

	for btn in $VBoxContainer.get_children():
		btn.add_theme_stylebox_override("normal",  bn)
		btn.add_theme_stylebox_override("hover",   bh)
		btn.add_theme_stylebox_override("pressed", bp)
		btn.add_theme_stylebox_override("focus",   bn)
		btn.add_theme_color_override("font_color",       Color(0, 1, 0.25, 1))
		btn.add_theme_color_override("font_hover_color", Color(0, 1, 0.25, 1))

func _ready() -> void:
	settings_panel.hide()
	_load_settings()
	_apply_styles()
	$VBoxContainer/PlayButton.pressed.connect(_on_play)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit)
	$InfoButton.pressed.connect(_on_info)
	$SettingsPanel/VolumeSlider.value_changed.connect(_on_vol_changed)
	$SettingsPanel/BackButton.pressed.connect(_on_back)
	audio.play_menu_bgm()

func _on_play() -> void:
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
func _on_quit() -> void:
	get_tree().quit()

func _on_settings() -> void:
	settings_panel.visible = !settings_panel.visible
	$Label2.visible = !settings_panel.visible

func _on_back() -> void:
	_save_settings()
	settings_panel.hide()
	$Label2.show()

func _on_info() -> void:
	OS.shell_open(GH_URL)

func _on_vol_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(volbus), linear_to_db(val))
