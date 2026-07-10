extends Area2D

var activated = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and not activated:
		activated = true
		$FlagEmpty.hide()
		$FlagRaised.show()
		body.checkpoint_position = global_position
