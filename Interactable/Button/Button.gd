extends StaticBody2D
signal pushed
signal released

var pushed = false setget set_push

func _ready():
	add_to_group("Buttons")

func _on_push(body):
	$Sprite.region_rect = Rect2(40, 48, 8, 8)
	emit_signal("pushed")

func _on_released(body):
	var overlap = $PushArea.get_overlapping_bodies()
	if overlap.size() <= 1:
		$Sprite.region_rect = Rect2(32, 48, 8, 8)
		emit_signal("released")

func set_push(value):
	if pushed:
		_on_released(self)
	else:
		_on_push(self)
	pushed = value
