extends AnimatableBody2D

@export var distance = 200.0
@export var speed = 2.0
@export var vertical = false

var start_pos

func _ready():
	start_pos = position

func _physics_process(delta):
	#sine to delecerate near edge/endpoint
	var offset = (-sin(Time.get_ticks_msec() / 1000.0 * speed)) * distance
	if vertical:
		position.y = start_pos.y + offset
	else:
		position.x = start_pos.x + offset
