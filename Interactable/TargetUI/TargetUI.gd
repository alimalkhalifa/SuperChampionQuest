extends Node2D

var target
var dying = false

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if target != null:
		position = target.position

func die():
	dying = true
	$Sprite.modulate = Color(0.5, 0.5, 0.5)
	target = null
	$Timer.start()


func _on_Timer_timeout():
	queue_free()
