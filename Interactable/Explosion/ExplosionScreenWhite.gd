extends Node2D

signal end
signal prime_end

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
	emit_signal("end")


func _on_PrimeTimer_timeout():
	emit_signal("prime_end")
