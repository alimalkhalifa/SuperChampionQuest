extends KinematicBody2D

export(NodePath) var startpos
export(NodePath) var pos2d_attack_up
export(NodePath) var pos2d_enrage
export(NodePath) var area_top_left_area
export(NodePath) var area_top_right_area
export(NodePath) var pos2d_bullet_enrageL_pos1
export(NodePath) var pos2d_bullet_enrageL_pos2
export(NodePath) var pos2d_bullet_enrageR_pos1
export(NodePath) var pos2d_bullet_enrageR_pos2
export(NodePath) var area_mid_area_l
export(NodePath) var area_mid_area_r
export(NodePath) var warning_center_warning
export(NodePath) var pos2d_egg_hit
export(NodePath) var pos2d_screen_hit
export(NodePath) var pos2d_topleft_button_pos
export(NodePath) var pos2d_topright_button_pos
export(NodePath) var pos2d_boss_end_pos

var pos_attack_up
var pos_enrage
var top_left_area
var top_right_area
var speed = 64
var target = null
var charge = 0
var cooldown = 1
var wait_for_attack = 1
var attack_nos = 0
var target_ui
var mid_area_l
var mid_area_r
var health = 3
var spawn_step = 0
var vulnerable = false
var egg_count = 0
var center_warning
var egg_hit
var egg
var screen_hit
var topleft_button_pos
var topright_button_pos
var boss_end_pos
var dying = false

enum State {
	NONE,
	ATTACK_UP,
	SOFT_ENRAGE,
	STUN,
	VULNERABLE,
	DIE
}

export var state = State.NONE

const ENRAGE_CHARGE = 3
const ATTACK_CHARGE = 1
const EGG_DROP = 2

func _ready():
	pos_attack_up = get_node(pos2d_attack_up).position
	pos_enrage = get_node(pos2d_enrage).position
	top_left_area = get_node(area_top_left_area)
	top_right_area = get_node(area_top_right_area)
	mid_area_l = get_node(area_mid_area_l)
	mid_area_r = get_node(area_mid_area_r)
	center_warning = get_node(warning_center_warning)
	egg_hit = get_node(pos2d_egg_hit)
	screen_hit = get_node(pos2d_screen_hit)
	topleft_button_pos = get_node(pos2d_topleft_button_pos)
	topright_button_pos = get_node(pos2d_topright_button_pos)
	boss_end_pos = get_node(pos2d_boss_end_pos)

func start():
	$Tween.interpolate_property(self, "position", position, get_node(startpos).position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _physics_process(delta):
	if state == State.NONE:
		return
	elif state == State.ATTACK_UP:
		var move_vector = pos_attack_up - position
		if $AnimationPlayer.current_animation != "Fly":
			$AnimationPlayer.play("Fly")
		if move_vector.length() < speed * delta:
			position = pos_attack_up
		else:
			position += move_vector.normalized() * speed * delta
		if target == null:
			var overlapL = top_left_area.get_overlapping_bodies()
			var overlapR = top_right_area.get_overlapping_bodies()
			var overlap = Array()
			if overlapL.size() > 0:
				overlap.push_back(overlapL[0])
			if overlapR.size() > 0:
				overlap.push_back(overlapR[0])
			if overlap.size() > 0:
				var rand = randi() % overlap.size()
				target = overlap[rand]
			else:
				state = State.SOFT_ENRAGE
				charge = 0
				cooldown = 1
		else:
			if target_ui != null and weakref(target_ui).get_ref() and not target_ui is preload("res://Interactable/TargetUI/TargetUI.gd"):
				target_ui.queue_free()
				target_ui = null
			if target_ui == null or not weakref(target_ui).get_ref() and cooldown == 0:
				target_ui = load("res://Interactable/TargetUI/TargetUI.tscn").instance()
				get_node("/root/Game").add_child(target_ui)
				target_ui.target = target
				target_ui.position = target.position
			var overlapL = top_left_area.get_overlapping_bodies()
			var overlapR = top_right_area.get_overlapping_bodies()
			if (overlapL.size() == 0 and overlapR.size() == 0) or (not top_left_area.overlaps_body(target) and not top_right_area.overlaps_body(target)):
				target = null
				if target_ui != null and weakref(target_ui).get_ref():
					target_ui.queue_free()
			else:
				if target.position.x - position.x < 0:
					$Faceable.scale = Vector2(1, 1)
				else:
					$Faceable.scale = Vector2(-1, 1)
				if cooldown <= 0:
					cooldown = 0
					charge += delta
					attack_nos = 1
				else:
					cooldown -= delta
				if charge > ATTACK_CHARGE:
					if target_ui != null and weakref(target_ui).get_ref() and target_ui is preload("res://Interactable/TargetUI/TargetUI.gd") and not target_ui.dying:
						target_ui.die()
					if wait_for_attack > 0:
						wait_for_attack -= delta
					else:
						var bullet = load("res://Interactable/Bullet/Bullet.tscn").instance()
						$AttacklSound.play()
						bullet.position = $Faceable/FlyFirePosition.global_position
						bullet.direction = (target_ui.position - bullet.position).normalized()
						get_node("/root/Game").add_child(bullet)
						attack_nos -= 1
						wait_for_attack = 1
						if attack_nos <= 0:
							charge = 0
							cooldown = 1
	elif state == State.SOFT_ENRAGE:
		var move_vector = pos_enrage - position
		if move_vector.length() < speed * delta:
			position = pos_enrage
			if $AnimationPlayer.current_animation != "FacingForward":
				$AnimationPlayer.play("FaceForward")
		else:
			position += move_vector.normalized() * speed * delta
			if $AnimationPlayer.current_animation != "Fly":
				$AnimationPlayer.play("Fly")
		if target == null:
			var overlapL = top_left_area.get_overlapping_bodies()
			var overlapR = top_right_area.get_overlapping_bodies()
			var overlap = Array()
			if overlapL.size() > 0:
				overlap.push_back(overlapL[0])
			if overlapR.size() > 0:
				overlap.push_back(overlapR[0])
			if overlap.size() > 0:
				var rand = randi() % overlap.size()
				target = overlap[rand]
			charge += delta
			if charge > ENRAGE_CHARGE:
				var bulletL = load("res://Interactable/BulletEnrage/BulletEnrage.tscn").instance()
				var bulletR = load("res://Interactable/BulletEnrage/BulletEnrage.tscn").instance()
				$AttacklSound.play()
				bulletL.position = $Faceable/ForwardFirePosition.global_position
				bulletR.position = $Faceable/ForwardFirePosition.global_position
				bulletL.pos1_node = pos2d_bullet_enrageL_pos1
				bulletL.pos2_node = pos2d_bullet_enrageL_pos2
				bulletR.pos1_node = pos2d_bullet_enrageR_pos1
				bulletR.pos2_node = pos2d_bullet_enrageR_pos2
				get_node("/root/Game").add_child(bulletL)
				get_node("/root/Game").add_child(bulletR)
				bulletL.explosion_hit = screen_hit
				state = State.NONE
				charge = 0
		else:
			state = State.ATTACK_UP
			charge = 0
	elif state == State.STUN:
		get_node("/root/Game").next_track = load("res://Music/HeartBeat.wav")
		get_node("/root/Game").next_track_immediate = true
		var move_vector = pos_attack_up - position
		if $AnimationPlayer.current_animation != "Fly":
			$AnimationPlayer.play("Fly")
		if move_vector.length() < speed * delta:
			position = pos_attack_up
		else:
			position += move_vector.normalized() * speed * delta
		target = null
	elif state == State.VULNERABLE:
		position = pos_attack_up
		$Faceable/EyeBlackout.visible = true
		$Faceable/EyeSprite.visible = true
	elif state == State.DIE:
		get_node("/root/Game").next_track = load("res://Music/HeartBeat.wav")
		get_node("/root/Game").next_track_immediate = true
		var move_vector = boss_end_pos.position - position
		if move_vector.length() < 8 * delta:
			var explosion = load("res://Interactable/Explosion/ExplosionScreenWhite.tscn").instance()
			explosion.position = screen_hit.position
			get_node("/root/Game").add_child(explosion)
			explosion.connect("end", get_node("/root/Game"), "_on_game_end")
			explosion.connect("prime_end", get_node("/root/Game"), "_on_prime_end")
			for p in get_tree().get_nodes_in_group("Platforms"):
				if weakref(p).get_ref():
					p.queue_free()
			queue_free()
		else:
			position += move_vector.normalized() * 8 * delta
		
func _on_Timer_timeout():
	if state != State.STUN and not vulnerable and not dying:
		$EggDropTimer.start()
		center_warning.visible = true
	if get_tree().get_nodes_in_group("PhaseEnemies").size() >= 8 or state == State.STUN or vulnerable == true:
		return
	if health < 2:
		return
	else:
		for i in range(4 - health):
			var head = load("res://Mobile/Skulltor/Skulltor.tscn").instance()
			if health == 2:
				head.drop_chance = 0.6
			var pos
			if spawn_step == 0:
				pos = mid_area_l.position + Vector2(24, 0).rotated(randf() * 2 * PI)
			else:
				pos = mid_area_r.position + Vector2(24, 0).rotated(randf() * 2 * PI)
			spawn_step = (spawn_step + 1) % 2
			head.position = pos
			get_node("/root/Game").add_child(head)

func hit(amount):
	if not vulnerable:
		$ChinkSound.play()
		return
	get_node("/root/Game").next_track = load("res://Music/Music4.wav")
	$HurtSound.play()
	health -= amount
	vulnerable = false
	state = State.ATTACK_UP
	$Faceable/EyeBlackout.visible = false
	$Faceable/EyeSprite.visible = false
	cooldown = 1
	charge = 0
	if health == 1:
		var button = load("res://Interactable/Button/Button.tscn")
		var topleftbutton = button.instance()
		var toprightbutton = button.instance()
		topleftbutton.position = topleft_button_pos.position
		toprightbutton.position = topright_button_pos.position
		get_node("/root/Game").add_child(topleftbutton)
		get_node("/root/Game").add_child(toprightbutton)
		topleftbutton.connect("pushed", get_node("/root/Game"), "_spawn_button_pushed")
		toprightbutton.connect("pushed", get_node("/root/Game"), "_spawn_button_pushed")
	elif health == 0:
		get_node("/root/Game").end_music = true
		dying = true
		var buttons = get_tree().get_nodes_in_group("Buttons")
		for b in buttons:
			b.queue_free()
		get_node("/root/Game/EngageParticles").visible = false
		state = State.DIE

func _on_EggDropTimer_timeout():
	if egg_count == 0:
		egg_count = 1
		$EggDropTimer.start()
		egg = load("res://Mobile/Boss/Egg.tscn").instance()
		egg.position = position
		get_node("/root/Game").add_child(egg)
		$Tween.interpolate_property(egg, "position", egg.position, egg_hit.position, 1, Tween.TRANS_QUAD, Tween.EASE_IN)
		$Tween.start()
	elif egg_count == 1:
		egg_count = 0
		center_warning.visible = false
		var explosion = load("res://Interactable/Explosion/Explosion6x8.tscn").instance()
		$ExplodeSound.play()
		explosion.position = egg_hit.position
		get_node("/root/Game").add_child(explosion)
		if egg != null and weakref(egg).get_ref():
			egg.queue_free()
		egg = null
