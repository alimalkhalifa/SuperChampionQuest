extends Area2D

var speed = 128
var direction = Vector2()

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	position += speed * direction * delta

func _on_Timer_timeout():
	queue_free()

func _on_Bullet_body_entered(body):
	if body.has_method("hit"):
		body.hit(1)
	queue_free()
