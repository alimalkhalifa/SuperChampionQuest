extends CenterContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_property($VBoxContainer/Label, "modulate",$VBoxContainer/Label.modulate , Color(1,1,1,1), 8, Tween.TRANS_LINEAR, Tween.EASE_IN, 2)
	$Tween.interpolate_property($VBoxContainer/Label2, "modulate", $VBoxContainer/Label2.modulate, Color(1,1,1,1), 8, Tween.TRANS_LINEAR, Tween.EASE_IN, 12)
	$Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene("res://Game.tscn")
