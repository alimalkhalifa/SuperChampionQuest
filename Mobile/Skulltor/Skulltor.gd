extends Node2D

var health = 1
var destination = Vector2()
var speed = 2
var target = Vector2()

export var drop_chance = 1.0

func _ready():
	destination = position + Vector2(8, 0).rotated(randi() * 2 * PI)
	add_to_group("PhaseEnemies")

func hit(amount):
	health -= amount
	$HurtSound.play()
	if health <= 0:
		die()

func _physics_process(delta):
	var move_vector = destination - position
	if move_vector.length() > speed * delta:
		position += move_vector.normalized() * speed * delta
	else:
		fire()
		destination = position + Vector2(8, 0).rotated(randi() * 2 * PI)

func fire():
	if has_node("/root/Game/Boss") and get_node("/root/Game/Boss").target != null:
		target = get_node("/root/Game/Boss").target.position
	else:
		var rand = randi() % 2
		var players = get_tree().get_nodes_in_group("Players")
		target = players[rand].position
	var bullet = load("res://Interactable/Bullet/Bullet.tscn").instance()
	$ShootSound.play()
	bullet.position = position
	bullet.direction = (target - position).normalized()
	get_node("/root/Game").add_child(bullet)

func die():
	if randf() <= drop_chance:
		var crystal = load("res://Interactable/CrystalShard/CrystalShard.tscn").instance()
		crystal.position = position
		get_node("/root/Game").add_child(crystal)
		crystal.connect("collected", get_node("/root/Game"), "_on_crystal_collected")
	queue_free()