extends Panel

var correct_code: String  = ""
var bomb_index: int       = 0
var game: Node            = null
var is_locked: bool       = true
var is_defused: bool      = false
var current_input: String = ""

@onready var code_input   = $CodeInput
@onready var status_label = $StatusLabel
@onready var num_label    = $BombNumLabel
@onready var anim         = $AnimationPlayer
@onready var numpad       = $Numpad

func _ready() -> void:
	pass
