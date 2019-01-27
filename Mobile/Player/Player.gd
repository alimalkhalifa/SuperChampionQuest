extends KinematicBody2D

export var player = 1
export(NodePath) var ui_health_label
var health_label
var velocity = Vector2()
var speed = 64.0
var gravity = 80.0
var jump_velocity = 65.0
var facing_freeze = false
var anim_state_machine
var attacking = false
var max_health = 5
var health = 5
var health_part = 0
var invulnerable = false

func _ready():
	add_to_group("Players")
	if player == 1:
		anim_state_machine = $AnimationTree["parameters/playback"]
	else:
		anim_state_machine = $AnimationTree2["parameters/playback"]		
	anim_state_machine.start("Idle")
	health_label = get_node(ui_health_label)

func _physics_process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene("res://Game.tscn")
	_do_move(delta)
	_do_move_input(delta)
	_do_attack(delta)
	_do_animate(delta)

func _do_move(delta):
	move_and_slide(velocity, Vector2.UP)
	
	if (is_on_floor()):
		velocity.y = 0
	if is_on_ceiling():
		velocity.y = 0
	if is_on_wall():
		velocity.x = 0

func _do_move_input(delta):
	var horizontal = 0
	if not attacking or not is_on_floor():
		horizontal = Input.get_action_strength("right_%d" % player) - Input.get_action_strength("left_%d" % player)
	
	if Input.is_action_just_pressed("jump_%d" % player) and is_on_floor():
		$JumpSound.play()
		velocity.y -= jump_velocity
	
	if is_on_floor():
		velocity.x = lerp(velocity.x, horizontal * speed, 8.0 * delta)
	else:
		velocity.x = lerp(velocity.x, horizontal * speed, 2.0 * delta)
	
	if velocity.y < 0 and Input.is_action_pressed("jump_%d" % player):
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * 2.5 * delta

func _do_attack(delta):
	if not attacking and anim_state_machine.is_playing() and Input.is_action_just_pressed("attack_%d" % player):
		attacking = true
		anim_state_machine.travel("Attack")

func _do_animate(delta):
	if not facing_freeze and anim_state_machine.is_playing() and not attacking:
		if velocity.x < -2:
			$Faceable.scale = Vector2(-1, 1)
			anim_state_machine.travel("Run")
		elif velocity.x > 2:
			$Faceable.scale = Vector2(1, 1)
			anim_state_machine.travel("Run")
		else:
			anim_state_machine.travel("Idle")

func _attack_check():
	var overlap = $Faceable/AttackArea.get_overlapping_areas()
	for o in overlap:
		var owner = o.get_parent()
		if owner.name == "Faceable":
			owner = owner.get_parent()
		if owner.has_method("hit"):
			owner.hit(1)

func _attack_done():
	attacking = false

func hit(amount):
	if invulnerable:
		return
	$HurtSound.play()
	health -= amount
	invulnerable = true
	$InvulTimer.start()
	$InvulAnimationPlayer.play("invul")
	health_label.text = "Health: %d" % health
	if health <= 0:
		get_node("/root/Game").queue_free()
		var gameover = load("res://Maps/GameOver.tscn").instance()
		get_node("/root").add_child(gameover)

func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
	health_label.text = "Health: %d" % health

func _on_InvulTimer_timeout():
	invulnerable = false
