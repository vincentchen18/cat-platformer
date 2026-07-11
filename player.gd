extends CharacterBody2D
@export var push_force = 2000.0
@onready var tilemap = $"../TileMapLayer"
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
	apply_arrow_push(delta)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if not body or body is TileMapLayer:
			continue
		if body.get_collision_layer_value(3):
			die()
	# death when y >= 450
	if global_position.y >= DEATH_Y or Input.is_action_pressed("restart"):
		die()

func die():
	global_position = checkpoint_position
	velocity = Vector2.ZERO
func apply_arrow_push(delta):
	var points = [
		global_position,
		global_position + Vector2(0, 16),
		global_position + Vector2(0, -16),
	]
	for p in points:
		var cell = tilemap.local_to_map(tilemap.to_local(p))
		var data = tilemap.get_cell_tile_data(cell)
		if data:
			var dir = data.get_custom_data("push_dir")
			if dir != Vector2.ZERO:
				# lift off the ground so friction doesn't eat the launch
				global_position.y -= 4
				if dir.x == 0:
					velocity = dir*push_force*0.25
				else:
					if is_on_floor():
						velocity = dir*push_force*5
					else:
						velocity = dir * push_force

				return
