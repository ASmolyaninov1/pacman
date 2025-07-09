extends RigidBody2D
var ghosts = ["blinky", "pinky", "inky", "clyde"]

func _ready():
	$AnimatedSprite2D.play(ghosts[randi() % ghosts.size()] + "-up")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
