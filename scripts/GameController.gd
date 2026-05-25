extends Node2D

const MEM_TIME = 15
const DEF_TIME = 30
const DIGIT_POOL = "1234567890"

@onready var codelabels = [$CodeDisplay/Code1, $CodeDisplay/Code2,
	$CodeDisplay/Code3, $CodeDisplay/Code4, $CodeDisplay/Code5]
@onready var bombs = [$BombContainer/Bomb1, $BombContainer/Bomb2,
	$BombContainer/Bomb3, $BombContainer/Bomb4]
@onready var timerdisp = $TimerDisplay
@onready var mem_tmr = $MemorizeTimer
@onready var def_tmr = $DefuseTimer
@onready var startpop = $StartPopup
@onready var winscreen = $WinScreen
@onready var failscreen = $FailScreen
@onready var phaselabel = $PhaseLabel
@onready var bombbox = $BombContainer
@onready var codebox = $CodeDisplay
@onready var audio = $AudioManager

var codes: Array[String] = []
var defused = 0
var won_at: float = 0.0

func _make_stylebox(col: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = col
	s.border_width_left = 0; s.border_width_right = 0
	s.border_width_top = 0; s.border_width_bottom = 0
	return s

func _ready() -> void:
	winscreen.hide()
	failscreen.hide()
	bombbox.hide()
	codebox.hide()
	timerdisp.hide()
	startpop.hide()

	startpop.add_theme_stylebox_override("panel", _make_stylebox(Color(0,0,0,1)))
	winscreen.add_theme_stylebox_override("panel", _make_stylebox(Color(0, 0.04, 0, 0.97)))
	failscreen.add_theme_stylebox_override("panel", _make_stylebox(Color(0.05, 0, 0, 0.97)))

	codebox.set_position(Vector2(280, 167))
	codebox.set_size(Vector2(520, 420))
	$CodeDisplay/CodeTitle.add_theme_color_override("font_color", Color(1, 0.15, 0.15, 1))
	$CodeDisplay/CodeTitle.add_theme_font_size_override("font_size", 67)

	var grn = Color(0, 1, 0.25, 1)
	for i in 5:
		codelabels[i].add_theme_color_override("font_color", grn)
		codelabels[i].add_theme_font_size_override("font_size", 52)

	$WinScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$WinScreen/ExitBtn.pressed.connect(_on_exit)
	$FailScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$FailScreen/ExitBtn.pressed.connect(_on_exit)

	_memorize_phase()

func _process(_delta: float) -> void:
	if def_tmr.time_left > 0:
		timerdisp.text = "%.1f" % def_tmr.time_left
	elif mem_tmr.time_left > 0:
		timerdisp.text = "%.1f" % mem_tmr.time_left

func _mkcode() -> String:
	var c = ""
	for i in 6:
		c += DIGIT_POOL[randi() % DIGIT_POOL.length()]
	return c

func _gen_codes() -> Array[String]:
	var res: Array[String] = []
	while res.size() < 5:
		var c = _mkcode()
		if !res.has(c):
			res.append(c)
	return res

func _memorize_phase() -> void:
	codes = _gen_codes()
	for i in 5:
		codelabels[i].text = codes[i]

	phaselabel.set_position(Vector2(150, 0))
	phaselabel.set_size(Vector2(800, 160))
	phaselabel.add_theme_font_size_override("font_size", 130)
	phaselabel.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	phaselabel.text = "MEMORIZE"
	phaselabel.show()

	timerdisp.set_position(Vector2(950, 10))
	timerdisp.set_size(Vector2(180, 60))
	timerdisp.add_theme_font_size_override("font_size", 52)
	timerdisp.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	timerdisp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timerdisp.show()

	codebox.show()
	mem_tmr.start(MEM_TIME)
	mem_tmr.timeout.connect(_defuse_phase)

func _defuse_phase() -> void:
	codebox.hide()

	phaselabel.set_position(Vector2(-70, 8))
	phaselabel.set_size(Vector2(280, 60))
	phaselabel.add_theme_font_size_override("font_size", 87)
	phaselabel.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	phaselabel.text = "DEFUSE"
	phaselabel.show()

	timerdisp.set_position(Vector2(890, 8))
	timerdisp.set_size(Vector2(220, 60))
	timerdisp.add_theme_font_size_override("font_size", 52)
	timerdisp.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	timerdisp.show()

	codes.shuffle()
	for i in 4:
		bombs[i].setup(codes[i], i, self)
	for i in 4:
		bombs[i].visible = (i == 0)

	bombs[0].set_locked(false)
	bombbox.set_position(Vector2(285, 18))
	bombbox.show()

	def_tmr.start(DEF_TIME)
	def_tmr.timeout.connect(_on_fail)
	audio.play_bgm()

func on_bomb_defused(bidx: int) -> void:
	defused += 1
	if defused >= 4:
		won_at = def_tmr.time_left
		def_tmr.stop()
	await get_tree().create_timer(0.3).timeout

	if defused >= 4:
		_on_win()
		return

	var nxt = bidx + 1
	if nxt < 4:
		bombs[bidx].visible = false
		bombs[nxt].visible = true
		bombs[nxt].set_locked(false)

func _on_win() -> void:
	def_tmr.stop()
	bombbox.hide()
	timerdisp.hide()
	phaselabel.hide()
	audio.play_defuse()

	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	var pname = cfg.get_value("player", "name", "Rookie")
	$WinScreen/PlayerLabel.text = pname + " defused the bomb."
	$WinScreen/TimeLabel.text = "Time left: %.1fs" % won_at
	winscreen.show()

func _on_fail() -> void:
	def_tmr.stop()
	bombbox.hide()
	timerdisp.hide()
	phaselabel.hide()
	audio.play_explosion()
	failscreen.show()

func _on_play_again() -> void:
	defused = 0
	get_tree().reload_current_scene()

func _on_exit() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
