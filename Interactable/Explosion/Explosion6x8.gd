extends Node2D

func _ready():
	add_to_group("Explosions")

func _process(delta):
	var bodies = $HitBox.get_overlapping_bodies()
	for b in bodies:
		if b.has_method("hit"):
			b.hit(1)

func _on_Timer_timeout():
	queue_free()
