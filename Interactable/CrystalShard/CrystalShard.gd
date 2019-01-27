extends Area2D
signal collected(shard)

var collected = false

func _ready():
	add_to_group("Crystals")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CrystalShard_body_entered(body):
	if collected:
		return
	collected = true
	body.heal(1)
	emit_signal("collected", self)
	$PickupSound.play()
