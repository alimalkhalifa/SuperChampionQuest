extends StaticBody2D
export var start_off = false
func _ready():
	add_to_group("Platforms")
	if start_off:
		$Sprite.modulate.a = 0
		collision_layer = 0
		collision_mask = 0

func start():
	$AnimationPlayer.play("Spawn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
