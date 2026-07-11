extends CharacterBody2D
@export var push_force = 1000
@onready var tilemap = $"../TileMapLayer"
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DEATH_Y = 500.0
const FRICTION = 600
const ACCELERATION = 800
const coyote_time = 0.06
var on_arrow: bool = false
var coyote_timer: float = 0.0
var checkpoint_position = Vector2.ZERO
var boostvelocity: Vector2 = Vector2.ZERO
var xvelocity: float = 0.0
var yvelocity: float = 0.0
@onready var sprite: Node2D = $Sprite2D

## DEBUG LINES: REMOVE THESE WHEN SHIP PROJECT ##
var flying = false
const FLY_SPEED = 1200.0
var fly_pressed_last = false
##


func _ready():
	checkpoint_position = global_position  # start point is the first checkpoint

func _physics_process(delta):
	## DEBUG CODE
	# toggle fly mode with F
	if Input.is_key_pressed(KEY_F) and not fly_pressed_last:
		flying = not flying
		velocity = Vector2.ZERO
	fly_pressed_last = Input.is_key_pressed(KEY_F)

	if flying:
		fly_movement(delta)
		return   # skip all normal movement/gravity/death
	## END DEBUG CODE
	if coyote_timer > 0:
		coyote_timer -= delta
	# gravity
	if not is_on_floor():
		yvelocity += GRAVITY * delta
	if is_on_floor():
		coyote_timer = coyote_time
		# Wipes out accumulated gravity weights entirely
		if yvelocity > 0:
			yvelocity = 0
		if boostvelocity.y > 0:
			boostvelocity.y = 0
			
	# jump space/up
	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_up")) and (is_on_floor() || coyote_timer > 0):
		coyote_timer = 0
		yvelocity = JUMP_VELOCITY
	if is_on_wall():
		xvelocity = 0
		boostvelocity.x = 0
	# left/right movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if direction > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		xvelocity = direction * SPEED
	else:
		xvelocity = 0
		
	boostvelocity.x = move_toward(boostvelocity.x, 0, 800 * delta) 
	boostvelocity.y = move_toward(boostvelocity.y, 0, 800 * delta)
	apply_arrow_push(delta)
	
	# SMART CAPPING: Handles the abs() separation checks cleanly
	if abs(boostvelocity.x) > 0:
		velocity.x = sign(boostvelocity.x) * maxf(abs(xvelocity), abs(boostvelocity.x))
	else:
		velocity.x = xvelocity
		
	# === THE ULTIMATE LEDGE FALLING FIXED BLOCK ===
	if not is_on_floor() and is_on_wall() and sign(xvelocity) == sign(get_wall_normal().x) * -1:
		# If pushing into a cliff edge, throw away vector friction and use pure gravity
		velocity.y = yvelocity
	else:
		velocity.y = yvelocity + boostvelocity.y
	move_and_slide()
	
	if is_on_ceiling():
		yvelocity = 0
		boostvelocity.y = 0

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if not body or body is TileMapLayer:
			continue
		if body.get_collision_layer_value(3):
			die()
			
	# death when y >= 500
	if global_position.y >= DEATH_Y or Input.is_action_pressed("restart"):
		die()

func die():
	global_position = checkpoint_position
	velocity = Vector2.ZERO
	xvelocity = 0
	yvelocity = 0
	boostvelocity = Vector2.ZERO

func apply_arrow_push(delta):
	var found = false
	for p in [global_position, global_position + Vector2(0, 16), global_position + Vector2(0, -16)]:
		var cell = tilemap.local_to_map(tilemap.to_local(p))
		var data = tilemap.get_cell_tile_data(cell)
		if data:
			var dir = data.get_custom_data("push_dir")
			if dir != Vector2.ZERO:
				found = true
				if not on_arrow:
					if dir.x == 0:
						yvelocity = 0
						boostvelocity = dir * push_force * 1.3   # vertical arrows
					else:
						boostvelocity = dir * push_force       # horizontal
				break
	on_arrow = found

# MORE DEBUG CODE
func fly_movement(delta):
	var dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		dir.y += 1
	velocity = dir.normalized() * FLY_SPEED
	move_and_slide()
