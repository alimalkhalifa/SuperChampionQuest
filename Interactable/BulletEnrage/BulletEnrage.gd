extends Node2D

export(NodePath) var pos1_node
export(NodePath) var pos2_node

var step = 0
var pos1
var pos2
var explosion_hit

func _ready():
	pos1 = get_node(pos1_node).position
	pos2 = get_node(pos2_node).position
	$Tween.interpolate_property(self, "position", position, pos1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Timer_timeout():
	$Tween.interpolate_property(self, "position", position, pos2, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	if step == 0:
		step = 1
		$Timer.start()
	elif step == 1:
		if explosion_hit != null:
			var explode = load("res://Interactable/Explosion/ExplosionScreen.tscn").instance()
			explode.position = explosion_hit.position
			get_node("/root/Game").add_child(explode)
		queue_free()
