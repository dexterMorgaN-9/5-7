extends Node2D


const MEMORIZE_TIME = 10.0
const DEFUSE_TIME   = 22.0
const NUM_CODES     = 5
const NUM_BOMBS     = 4
const LETTERS       = "ABCDEFGHJKLMNPQRSTUVWXYZ"
const DIGITS        = "012346789"

# 
@onready var code_labels    = [$CodeDisplay/Code1, $CodeDisplay/Code2,
							   $CodeDisplay/Code3, $CodeDisplay/Code4, $CodeDisplay/Code5]
@onready var bombs          = [$BombContainer/Bomb1, $BombContainer/Bomb2,
							   $BombContainer/Bomb3, $BombContainer/Bomb4]
@onready var timer_display  = $TimerDisplay
@onready var mem_timer      = $MemorizeTimer
@onready var def_timer      = $DefuseTimer
@onready var start_popup    = $StartPopup
@onready var win_screen     = $WinScreen
@onready var fail_screen    = $FailScreen
@onready var phase_label    = $PhaseLabel
@onready var bomb_container = $BombContainer
@onready var code_display   = $CodeDisplay
@onready var audio          = $AudioManager
