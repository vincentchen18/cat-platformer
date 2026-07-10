extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DEATH_Y = 500.0
const coyote_time = 0.06

var coyote_timer: float = 0.0
var checkpoint_position = Vector2.ZERO

func _ready():
	checkpoint_position = global_position  # start point is the first checkpoint

func _physics_process(delta):
	if coyote_timer > 0:
		coyote_timer -= delta
	# gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if is_on_floor():
		coyote_timer = coyote_time
	# jump space/up
	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")) and (is_on_floor() || coyote_timer > 0):
		coyote_timer = 0
		velocity.y = JUMP_VELOCITY

	# left/right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# death when y >= 450
	if global_position.y >= DEATH_Y or Input.is_action_pressed("restart"):
		die()

func die():
	global_position = checkpoint_position
	velocity = Vector2.ZERO
