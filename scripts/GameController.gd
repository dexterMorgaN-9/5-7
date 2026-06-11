extends Node2D

const MEM_TIME = 14.5
const DEF_TIME = 30
const DIGIT_POOL = "1234567890"

@onready var codelabels = [$CodeDisplay/Code1, $CodeDisplay/Code2,
	$CodeDisplay/Code3, $CodeDisplay/Code4, $CodeDisplay/Code5]
@onready var bombs = [$BombContainer/Bomb1, $BombContainer/Bomb2,
	$BombContainer/Bomb3, $BombContainer/Bomb4]
@onready var timerdisp  = $TimerDisplay
@onready var mem_tmr    = $MemorizeTimer
@onready var def_tmr    = $DefuseTimer
@onready var startpop   = $StartPopup
@onready var winscreen  = $WinScreen
@onready var failscreen = $FailScreen
@onready var bombbox    = $BombContainer
@onready var codebox    = $CodeDisplay
@onready var audio      = $AudioManager

var codes: Array[String] = []
var defused = 0
var won_at: float = 0.0

var sidebar: Control = null
var divider: ColorRect = null
var sb_timerval: Label = null
var sb_dots: Array = []


func _make_sbox(col: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = col
	s.border_width_left = 0; s.border_width_right = 0
	s.border_width_top  = 0; s.border_width_bottom = 0
	return s

func _mono_lbl(txt: String, sz: int, col: Color) -> Label:
	var lbl = Label.new()
	lbl.text = txt
	var f = load("res://assets/fonts/digital-7 (mono).ttf")
	if f:
		lbl.add_theme_font_override("font", f)
	lbl.add_theme_font_size_override("font_size", sz)
	lbl.add_theme_color_override("font_color", col)
	return lbl

func _hline(x: float, y: float) -> ColorRect:
	var r = ColorRect.new()
	r.color = Color(0, 1, 0.25, 0.18)
	r.set_position(Vector2(x, y))
	r.set_size(Vector2(232, 1))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _build_sidebar() -> void:
	var _green     = Color(0, 1, 0.25, 1)
	var green_dim = Color(0, 1, 0.25, 0.4)
	var red       = Color(1, 0.3, 0.3, 1)
	var grey      = Color(0.45, 0.45, 0.45, 1)

	sidebar = Control.new()
	sidebar.name = "Sidebar"
	sidebar.set_position(Vector2(0, 0))
	sidebar.set_size(Vector2(280, 620))
	sidebar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sidebar)

	divider = ColorRect.new()
	divider.name = "Divider"
	divider.color = Color(0, 1, 0.25, 0.3)
	divider.set_position(Vector2(280, 0))
	divider.set_size(Vector2(2, 620))
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(divider)

	var timer_hdr = _mono_lbl("TIMER", 18, grey)
	timer_hdr.set_position(Vector2(24, 28))
	sidebar.add_child(timer_hdr)

	sb_timerval = _mono_lbl("30.0", 72, red)
	sb_timerval.set_position(Vector2(18, 50))
	sb_timerval.set_size(Vector2(240, 80))
	sidebar.add_child(sb_timerval)

	var timer_sub = _mono_lbl("seconds remaining", 16, grey)
	timer_sub.set_position(Vector2(24, 128))
	sidebar.add_child(timer_sub)
	sidebar.add_child(_hline(24, 162))

	var prog_hdr = _mono_lbl("PROGRESS", 18, grey)
	prog_hdr.set_position(Vector2(24, 180))
	sidebar.add_child(prog_hdr)

	sb_dots.clear()
	for i in 4:
		var sq = ColorRect.new()
		sq.set_size(Vector2(32, 32))
		sq.set_position(Vector2(24 + i * 46, 210))
		sq.color = green_dim
		sq.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sidebar.add_child(sq)
		sb_dots.append(sq)

	sidebar.add_child(_hline(24, 260))

	var stat_hdr = _mono_lbl("STATUS", 18, grey)
	stat_hdr.set_position(Vector2(24, 278))
	sidebar.add_child(stat_hdr)

	var dot = ColorRect.new()
	dot.name = "SB_Dot"
	dot.set_size(Vector2(14, 14))
	dot.set_position(Vector2(24, 316))
	dot.color = red
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sidebar.add_child(dot)

	var stat_lbl = _mono_lbl("ARMED", 36, red)
	stat_lbl.name = "SB_Status"
	stat_lbl.set_position(Vector2(46, 302))
	sidebar.add_child(stat_lbl)

func _sb_tick(t: float) -> void:
	if sb_timerval:
		sb_timerval.text = "%.1f" % t
		if t < 10.0:
			sb_timerval.add_theme_color_override("font_color", Color(1, 0.5, 0.1, 1))

func _sb_progupdate(bidx: int) -> void:
	for i in 4:
		if i < bidx:
			sb_dots[i].color = Color(0, 1, 0.25, 1)
		elif i == bidx:
			sb_dots[i].color = Color(0, 1, 0.25, 0.7)
		else:
			sb_dots[i].color = Color(0, 1, 0.25, 0.2)

func _sb_setstatus(txt: String, col: Color) -> void:
	var lbl = sidebar.get_node_or_null("SB_Status")
	if lbl:
		lbl.text = txt
		lbl.add_theme_color_override("font_color", col)
	var dot = sidebar.get_node_or_null("SB_Dot")
	if dot:
		dot.color = col

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

func _ready() -> void:
	winscreen.hide()
	failscreen.hide()
	bombbox.hide()
	codebox.hide()
	timerdisp.hide()
	startpop.hide()
	$BGOverlay.hide()

	startpop.add_theme_stylebox_override("panel", _make_sbox(Color(0,0,0,1)))
	winscreen.add_theme_stylebox_override("panel", _make_sbox(Color(0, 0.04, 0, 0.97)))
	failscreen.add_theme_stylebox_override("panel", _make_sbox(Color(0.05, 0, 0, 0.97)))

	codebox.set_position(Vector2(200, 80))
	codebox.set_size(Vector2(720, 480))

	$CodeDisplay/CodeTitle.add_theme_color_override("font_color", Color(0, 1, 0.25, 0.45))
	$CodeDisplay/CodeTitle.add_theme_font_size_override("font_size", 67)

	for i in 5:
		codelabels[i].add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
		codelabels[i].add_theme_font_size_override("font_size", 64)

	$WinScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$WinScreen/ExitBtn.pressed.connect(_on_exit)
	$FailScreen/PlayAgainBtn.pressed.connect(_on_play_again)
	$FailScreen/ExitBtn.pressed.connect(_on_exit)

	_memorize_phase()
	audio.play_memorize_bgm()
		 
func _process(_delta: float) -> void:
	if def_tmr.time_left > 0:
		timerdisp.text = "%.1f" % def_tmr.time_left
		_sb_tick(def_tmr.time_left)
	elif mem_tmr.time_left > 0:
		timerdisp.text = "%.1f" % mem_tmr.time_left

func _memorize_phase() -> void:
	codes = _gen_codes()
	for i in 5:
		codelabels[i].text = codes[i]

	timerdisp.set_position(Vector2(720, -47))
	timerdisp.set_size(Vector2(250, 60))
	timerdisp.add_theme_font_size_override("font_size", 52)
	timerdisp.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	timerdisp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timerdisp.show()

	codebox.show()
	mem_tmr.start(MEM_TIME)
	mem_tmr.timeout.connect(_defuse_phase)
	audio.play_defuse_bgm()

func _defuse_phase() -> void:
	codebox.hide()
	timerdisp.hide()
	_build_sidebar()

	codes.shuffle()
	for i in 4:
		bombs[i].setup(codes[i], i, self)

	for i in 4:
		bombs[i].visible = (i == 0)

	bombs[0].set_locked(false)
	bombbox.set_position(Vector2(285, 10))

	for b in bombs:
		b.custom_minimum_size = Vector2(760, 620)
	bombbox.show()

	_sb_progupdate(0)
	_sb_setstatus("ARMED", Color(1, 0.3, 0.3, 1))
	def_tmr.start(DEF_TIME)
	def_tmr.timeout.connect(_on_fail)
	audio.play_defuse_bgm()

func on_bomb_defused(bidx: int) -> void:
	defused += 1

	if bidx < sb_dots.size():
		sb_dots[bidx].color = Color(0, 1, 0.25, 1)

	if defused >= 4:
		won_at = def_tmr.time_left
		def_tmr.stop()
		_sb_setstatus("DEFUSED", Color(0, 1, 0.25, 1))

	await get_tree().create_timer(0.3).timeout

	if defused >= 4:
		_on_win()
		return

	var nxt = bidx + 1
	if nxt < 4:
		bombs[bidx].visible = false
		bombs[nxt].visible  = true
		bombs[nxt].set_locked(false)
		_sb_progupdate(nxt)
		_sb_setstatus("ARMED", Color(1, 0.3, 0.3, 1))

func _on_win() -> void:
	def_tmr.stop()
	bombbox.hide()
	if sidebar: sidebar.hide()
	if divider: divider.hide()
	audio.play_win_bgm()

	var cfg = ConfigFile.new()
	cfg.load("user://settings.cfg")
	var pname = cfg.get_value("player", "name", "Rookie")
	$WinScreen/PlayerLabel.text = pname + " defused the bomb."
	$WinScreen/TimeLabel.text   = "Time left: %.1fs" % won_at
	winscreen.show()

func _on_fail() -> void:
	def_tmr.stop()
	bombbox.hide()
	if sidebar: sidebar.hide()
	if divider: divider.hide()
	audio.play_fail_bgm()
	failscreen.show()

func _on_play_again() -> void:
	defused = 0
	get_tree().reload_current_scene()

func _on_exit() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
