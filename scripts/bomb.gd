extends Panel

var correct: String = ""
var bidx: int = 0
var game: Node = null
var locked: bool = true
var defused: bool = false
var inp: String = ""
var _last_key = null

@onready var codeinput = $CodeInput
@onready var statuslbl = $StatusLabel
@onready var numlbl    = $BombNumLabel
@onready var anim      = $AnimationPlayer
@onready var numpad    = $Numpad

var _keys = ["1","2","3","4","5","6","7","8","9","*","0","#"]

func _mk_sbox(bg: Color, bw: int, bcol := Color(0,0,0,0), cr := 0) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_width_left = bw; s.border_width_top = bw
	s.border_width_right = bw; s.border_width_bottom = bw
	if bw > 0:
		s.border_color = bcol
		s.corner_radius_top_left = cr; s.corner_radius_top_right = cr
		s.corner_radius_bottom_right = cr; s.corner_radius_bottom_left = cr
	return s

func _build_numpad() -> void:
	for child in numpad.get_children():
		child.queue_free()

	var s_norm  = _mk_sbox(Color(0,0,0,0), 0)
	var s_hover = _mk_sbox(Color(0, 1, 0.2, 0.18), 1, Color(0, 1, 0.25, 0.55), 3)
	var s_press = _mk_sbox(Color(0, 1, 0.35, 0.50), 1, Color(0, 1, 0.254, 1), 3)

	for k in _keys:
		var btn = Button.new()
		btn.text = k
		btn.custom_minimum_size = Vector2(25, 18)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_stylebox_override("normal",   s_norm)
		btn.add_theme_stylebox_override('hover',    s_hover)
		btn.add_theme_stylebox_override("pressed",  s_press)
		btn.add_theme_stylebox_override("disabled", s_norm)
		btn.add_theme_stylebox_override('focus',    s_norm)
		btn.pressed.connect(_on_key.bind(k))
		numpad.add_child(btn)

func _ready() -> void:
	var transparent = StyleBoxFlat.new()
	transparent.bg_color = Color(0, 0, 0, 0)
	add_theme_stylebox_override("panel", transparent)
	$BombNumLabel.hide()

func setup(code: String, idx: int, gnode: Node) -> void:
	correct = code
	bidx    = idx
	game    = gnode
	inp = ""
	numlbl.text  = "BOMB %d/4" % (idx + 1)
	statuslbl.text = "ARMED"
	statuslbl.add_theme_color_override("font_color", Color(1, 0.26, 0.26, 1))
	codeinput.text = ""
	_build_numpad()

func set_locked(val: bool) -> void:
	locked = val
	numpad.modulate.a = 0.0 if val else 1.0
	numpad.mouse_filter = Control.MOUSE_FILTER_IGNORE if val else Control.MOUSE_FILTER_STOP
	if !val:
		statuslbl.text = "ENTER CODE"
		statuslbl.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	else:
		statuslbl.text = "LOCKED"
		statuslbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

func _input(event: InputEvent) -> void:
	if locked or defused: return
	if not event is InputEventKey: return
	if not event.pressed: return

	var kc = event.keycode
	if kc >= KEY_1 and kc <= KEY_9:
		_on_key(str(kc - KEY_0))
	elif kc == KEY_0:
		_on_key("0")
	elif kc >= KEY_KP_1 and kc <= KEY_KP_9:
		_on_key(str(kc - KEY_KP_0))
	elif kc == KEY_KP_0:
		_on_key("0")
	elif kc == KEY_BACKSPACE:
		_on_key("*")
	elif kc == KEY_ENTER or kc == KEY_KP_ENTER:
		_on_key("#")
	get_viewport().set_input_as_handled()

func _check() -> void:
	if inp == correct:
		_defuse()
	else:
		_wrong()

func _on_key(k: String) -> void:
	if locked or defused: return
	game.audio.play_click()

	match k:
		"*":
			if inp.length() > 0:
				inp = inp.left(inp.length() - 1)
				codeinput.text = inp
		"#":
			_check()
		_:
			if inp.length() < 6:
				inp += k
				codeinput.text = inp
				if inp.length() == 6:
					_check()

func _defuse() -> void:
	defused = true
	locked  = true
	numpad.modulate.a = 0.0
	numpad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	codeinput.text = correct
	statuslbl.text = " DEFUSED"
	statuslbl.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	anim.play("defuse_flash")
	game.on_bomb_defused(bidx)

func _wrong() -> void:
	inp = ""
	codeinput.text = ""
	statuslbl.text = "WRONG — RETRY"
	statuslbl.add_theme_color_override("font_color", Color(1, 0.3, 0.1, 1))
	anim.play("wrong_flash")
	game.audio.play_beep()
	await get_tree().create_timer(0.8).timeout
	if !defused:
		statuslbl.text = "ENTER CODE"
		statuslbl.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
