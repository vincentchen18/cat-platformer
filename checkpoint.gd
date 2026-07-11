extends Area2D

@export var is_final = false
var activated = false

func _ready():
	add_to_group("checkpoints")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not activated:
		activated = true
		$FlagEmpty.hide()
		$FlagRaised.show()
		body.checkpoint_position = global_position
		if is_final:
			body.win()
