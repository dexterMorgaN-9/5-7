extends Node2D

const MEMORIZE_TIME = 14.0
const DEFUSE_TIME = 22.0
const NUM_CODES = 5
const NUM_BOMBS = 4
const DIGITS = "0123456789"

@onready var code_labels = [$CodeDisplay/Code1, $CodeDisplay/Code2,
							$CodeDisplay/Code3, $CodeDisplay/Code4, $CodeDisplay/Code5]
@onready var bombs = [$BombContainer/Bomb1, $BombContainer/Bomb2,
					  $BombContainer/Bomb3, $BombContainer/Bomb4]
@onready var timer_display = $TimerDisplay
@onready var mem_timer = $MemorizeTimer
@onready var def_timer = $DefuseTimer
@onready var start_popup = $StartPopup
@onready var win_screen = $WinScreen
@onready var fail_screen = $FailScreen
@onready var phase_label = $PhaseLabel
@onready var bomb_container = $BombContainer
@onready var code_display = $CodeDisplay
@onready var audio = $AudioManager

var codes: Array[String] = []
var defused_count: int = 0
var time_when_won: float = 0.0

func _ready() -> void:
	win_screen.hide()
	fail_screen.hide()
	bomb_container.hide()
	code_display.hide()
	timer_display.hide()
	start_popup.hide()

	var black = StyleBoxFlat.new()
	black.bg_color = Color(0, 0, 0, 1)
	black.border_width_left = 0; black.border_width_right = 0
	black.border_width_top = 0; black.border_width_bottom = 0

	var win_style = StyleBoxFlat.new()
	win_style.bg_color = Color(0, 0.04, 0, 0.97)
	win_style.border_width_left = 0; win_style.border_width_right = 0
	win_style.border_width_top = 0; win_style.border_width_bottom = 0

	var fail_style = StyleBoxFlat.new()
	fail_style.bg_color = Color(0.05, 0, 0, 0.97)
	fail_style.border_width_left = 0; fail_style.border_width_right = 0
	fail_style.border_width_top = 0; fail_style.border_width_bottom = 0

	start_popup.add_theme_stylebox_override("panel", black)
	win_screen.add_theme_stylebox_override("panel", win_style)
	fail_screen.add_theme_stylebox_override("panel", fail_style)

	code_display.set_position(Vector2(280, 167))
	code_display.set_size(Vector2(520, 420))
	$CodeDisplay/CodeTitle.add_theme_color_override("font_color", Color(1, 0.15, 0.15, 1))
	$CodeDisplay/CodeTitle.add_theme_font_size_override("font_size", 47)

	var green = Color(0, 1, 0.25, 1)
	for i in 5:
		code_labels[i].add_theme_color_override("font_color", green)
		code_labels[i].add_theme_font_size_override("font_size", 52)

	$WinScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$WinScreen/ExitBtn.pressed.connect(_on_exit)
	$FailScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$FailScreen/ExitBtn.pressed.connect(_on_exit)

	_start_memorize_phase()

func _process(_delta: float) -> void:
	if def_timer.time_left > 0:
		timer_display.text = "%.1f" % def_timer.time_left
	elif mem_timer.time_left > 0:
		timer_display.text = "%.1f" % mem_timer.time_left

func _make_code() -> String:
	var code = ""
	for i in 6:
		code += DIGITS[randi() % DIGITS.length()]
	return code

func _generate_codes() -> Array[String]:
	var result: Array[String] = []
	while result.size() < NUM_CODES:
		var code = _make_code()
		if !result.has(code):
			result.append(code)
	return result

func _start_memorize_phase() -> void:
	codes = _generate_codes()
	for i in NUM_CODES:
		code_labels[i].text = codes[i]

	phase_label.set_position(Vector2(150, 0))
	phase_label.set_size(Vector2(800, 160))
	phase_label.add_theme_font_size_override("font_size", 130)
	phase_label.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	phase_label.text = "MEMORIZE"

	timer_display.set_position(Vector2(950, 10))
	timer_display.set_size(Vector2(180, 60))
	timer_display.add_theme_font_size_override("font_size", 52)
	timer_display.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	timer_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_display.show()

	code_display.show()
	mem_timer.start(MEMORIZE_TIME)
	mem_timer.timeout.connect(_start_defuse_phase)

func _start_defuse_phase() -> void:
	code_display.hide()

	phase_label.set_position(Vector2(-70, 8))
	phase_label.set_size(Vector2(280, 60))
	phase_label.add_theme_font_size_override("font_size", 87)
	phase_label.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	phase_label.text = "DEFUSE"

	timer_display.set_position(Vector2(890, 8))
	timer_display.set_size(Vector2(220, 60))
	timer_display.add_theme_font_size_override("font_size", 52)
	timer_display.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	timer_display.show()

	codes.shuffle()
	for i in NUM_BOMBS:
		bombs[i].setup(codes[i], i, self)

	for i in NUM_BOMBS:
		bombs[i].visible = (i == 0)

	bombs[0].set_locked(false)
	bomb_container.set_position(Vector2(285, 18))
	bomb_container.show()

	def_timer.start(DEFUSE_TIME)
	def_timer.timeout.connect(_on_fail)
	audio.play_bgm()

func on_bomb_defused(bomb_index: int) -> void:
	defused_count += 1
	await get_tree().create_timer(0.3).timeout

	if defused_count >= NUM_BOMBS:
		_on_win()
		return

	var nxt = bomb_index + 1
	if nxt < NUM_BOMBS:
		bombs[bomb_index].visible = false
		bombs[nxt].visible = true
		bombs[nxt].set_locked(false)

func _on_win() -> void:
	time_when_won = def_timer.time_left
	def_timer.stop()
	bomb_container.hide()
	timer_display.hide()
	audio.play_defuse()

	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	var pname = cfg.get_value("player", "name", "Rookie")
	$WinScreen/PlayerLabel.text = pname + " defused the bomb."
	$WinScreen/TimeLabel.text = "Time left: %.1fs" % time_when_won
	win_screen.show()

func _on_fail() -> void:
	def_timer.stop()
	bomb_container.hide()
	timer_display.hide()
	audio.play_explosion()
	fail_screen.show()

func _on_play_again() -> void:
	defused_count = 0
	get_tree().reload_current_scene()

func _on_exit() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
