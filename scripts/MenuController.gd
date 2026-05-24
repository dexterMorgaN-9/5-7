extends Control

@onready var settings_panel = $SettingsPanel
@onready var name_input = $SettingsPanel/NameInput
@onready var vol_slider = $SettingsPanel/VolumeSlider

const SETTINGS_PATH = "user://settings.cfg"
const GITHUB_URL = "https://github.com/dexterMorgaN-9/5-7/blob/main/README.md"

var _vol_bus = "Master"

func _ready() -> void:
	settings_panel.hide()
	_load_settings()
	_apply_styles()

	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$InfoButton.pressed.connect(_on_info_pressed)
	$SettingsPanel/VolumeSlider.value_changed.connect(_on_volume_changed)

func _apply_styles() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.92)
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0
	$SettingsPanel.add_theme_stylebox_override("panel", style)

func _load_settings() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		name_input.text = cfg.get_value("player", "name", "Rookie")
		var vol = cfg.get_value("audio", "volume", 0.8)
		vol_slider.value = vol
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(_vol_bus),
			linear_to_db(vol)
		)
	else:
		name_input.text = "Rookie"
		vol_slider.value = 0.8

func _save_settings() -> void:
	var cfg = ConfigFile.new()
	var pname = name_input.text.strip_edges()
	if pname.is_empty():
		pname = "Rookie"
	cfg.set_value("player", "name", pname)
	cfg.set_value("audio", "volume", vol_slider.value)
	cfg.save(SETTINGS_PATH)

func _on_play_pressed() -> void:
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	settings_panel.visible = !settings_panel.visible

func _on_info_pressed() -> void:
	OS.shell_open(GITHUB_URL)

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(_vol_bus),
		linear_to_db(value)
	)
