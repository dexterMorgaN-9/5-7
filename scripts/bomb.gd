extends Panel

var correct_code: String = ""
var bomb_index: int = 0
var game: Node = null
var is_locked: bool = true
var is_defused: bool = false
var cur_input: String = ""

@onready var code_input = $CodeInput
@onready var status_label = $StatusLabel
@onready var num_label = $BombNumLabel
@onready var anim = $AnimationPlayer
@onready var numpad = $Numpad

var _keys = ["1","2","3","4","5","6","7","8","9","*","0","#"]

func _ready() -> void:
	pass

func setup(code: String, idx: int, game_node: Node) -> void:
	correct_code = code
	bomb_index = idx
	game = game_node
	cur_input = ""
	num_label.text = "BOMB %d/4" % (idx + 1)
	status_label.text = "ARMED"
	status_label.add_theme_color_override("font_color", Color(1, 0.26, 0.26, 1))
	code_input.text = ""
	_build_numpad()

func _build_numpad() -> void:
	for child in numpad.get_children():
		child.queue_free()

	for k in _keys:
		var btn = Button.new()
		btn.text = ""
		btn.custom_minimum_size = Vector2(25, 18)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var s_normal = StyleBoxFlat.new()
		s_normal.bg_color = Color(0, 0, 0, 0)
		s_normal.border_width_left = 0; s_normal.border_width_top = 0
		s_normal.border_width_right = 0; s_normal.border_width_bottom = 0

		var s_hover = StyleBoxFlat.new()
		s_hover.bg_color = Color(0, 1, 0.2, 0.18)
		s_hover.border_width_left = 1; s_hover.border_width_top = 1
		s_hover.border_width_right = 1; s_hover.border_width_bottom = 1
		s_hover.border_color = Color(0, 1, 0.25, 0.55)
		s_hover.corner_radius_top_left = 3; s_hover.corner_radius_top_right = 3
		s_hover.corner_radius_bottom_right = 3; s_hover.corner_radius_bottom_left = 3

		var s_pressed = StyleBoxFlat.new()
		s_pressed.bg_color = Color(0, 1, 0.35, 0.50)
		s_pressed.border_width_left = 1; s_pressed.border_width_top = 1
		s_pressed.border_width_right = 1; s_pressed.border_width_bottom = 1
		s_pressed.border_color = Color(0, 1, 0.254, 1)
		s_pressed.corner_radius_top_left = 3; s_pressed.corner_radius_top_right = 3
		s_pressed.corner_radius_bottom_right = 3; s_pressed.corner_radius_bottom_left = 3

		btn.add_theme_stylebox_override("normal", s_normal)
		btn.add_theme_stylebox_override("hover", s_hover)
		btn.add_theme_stylebox_override("pressed", s_pressed)
		btn.add_theme_stylebox_override("disabled", s_normal)
		btn.add_theme_stylebox_override("focus", s_normal)

		btn.pressed.connect(_on_key_pressed.bind(k))
		numpad.add_child(btn)

func set_locked(locked: bool) -> void:
	is_locked = locked
	numpad.modulate.a = 0.0 if locked else 1.0
	numpad.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP
	if !locked:
		status_label.text = "ENTER CODE"
		status_label.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	else:
		status_label.text = "LOCKED"
		status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

func _input(event: InputEvent) -> void:
	if is_locked or is_defused:
		return
	if not event is InputEventKey:
		return
	if not event.pressed:
		return

	var kc = event.keycode

	if kc >= KEY_1 and kc <= KEY_9:
		_on_key_pressed(str(kc - KEY_0))
	elif kc == KEY_0:
		_on_key_pressed("0")
	elif kc >= KEY_KP_1 and kc <= KEY_KP_9:
		_on_key_pressed(str(kc - KEY_KP_0))
	elif kc == KEY_KP_0:
		_on_key_pressed("0")
	elif kc == KEY_BACKSPACE:
		_on_key_pressed("*")
	elif kc == KEY_ENTER or kc == KEY_KP_ENTER:
		_on_key_pressed("#")

	get_viewport().set_input_as_handled()

func _on_key_pressed(key: String) -> void:
	if is_locked or is_defused:
		return

	match key:
		"*":
			if cur_input.length() > 0:
				cur_input = cur_input.left(cur_input.length() - 1)
				code_input.text = cur_input
		"#":
			_check_code()
		_:
			if cur_input.length() < 6:
				cur_input += key
				code_input.text = cur_input
				if cur_input.length() == 6:
					_check_code()

func _check_code() -> void:
	if cur_input == correct_code:
		_defuse()
	else:
		_wrong_entry()

func _defuse() -> void:
	is_defused = true
	is_locked = true
	numpad.modulate.a = 0.0
	numpad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	code_input.text = correct_code
	status_label.text = "✓ DEFUSED"
	status_label.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
	anim.play("defuse_flash")
	game.on_bomb_defused(bomb_index)

func _wrong_entry() -> void:
	cur_input = ""
	code_input.text = ""
	status_label.text = "WRONG — RETRY"
	status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.1, 1))
	anim.play("wrong_flash")
	game.audio.play_beep()
	await get_tree().create_timer(0.8).timeout
	if !is_defused:
		status_label.text = "ENTER CODE"
		status_label.add_theme_color_override("font_color", Color(0, 1, 0.25, 1))
