extends Control

@onready var money_label: Label = $Cash
@onready var time_label: Label = $Time
@onready var sun: TextureRect = $Time/Sun

var player: Player
var money: int

var radius: float = 30
var speed: float
var angle: float

var reset_angle: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await GlobalVariables.wait_till_game_loaded()
	player = GlobalVariables.player
	money = player.money
	
	reset_angle = atan(sun.size.y/sun.size.x) # to angle 0
	angle = PI + reset_angle
	GlobalVariables.day_ended.connect(_sun_circular_motion.bind(true))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#Money
	money_label.text = str(money) + " $"
	money = player.money
	
	# current day/daytime
	time_label.text = "Day: " + str(GlobalVariables.current_day)
	_sun_circular_motion(false)
	

func _sun_circular_motion(reset: bool) -> void:
	speed = (TAU + 2 * reset_angle) / GlobalVariables.day_duration_sec / 2 # half circle in day_duration
	if reset:
		angle = PI + reset_angle
		print("reset")
	else:
		angle -= speed * get_process_delta_time()
	sun.position.x = radius * cos(angle) + 89
	sun.position.y = radius * sin(angle) + 43
