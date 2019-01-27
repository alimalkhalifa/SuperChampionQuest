extends Node2D

var phase = 0
var start_button_pressed_count = 0

var shard_num = 0

var next_track
var next_track_immediate = false
var end_music = false
var track_progression_repeat = false

func _ready():
	pass

func _start_button_pressed():
	if phase > 0:
		return
	start_button_pressed_count += 1
	if start_button_pressed_count >= 2:
		$MusicPlayer.play()
		phase = 1
		$EngageParticles.visible = true
		$StartEngageWarning.visible = true
		$Platform.start()
		$Platform2.start()
		yield(get_tree().create_timer(8), "timeout")
		$Boss.start()
		yield($Boss/Tween, "tween_completed")
		$EngageParticles.visible = false
		$EngageParticles.position += Vector2(0, -24)
		$StartEngageWarning.queue_free()
		$Map1.queue_free()
		var map2 = load("res://Maps/Map2.tscn").instance()
		add_child(map2)
		$Platform.queue_free()
		$Platform2.queue_free()
		$StartEngagementButton1.queue_free()
		$StartEngagementButton2.queue_free()
		var overlap = $BottomAreaHitBox.get_overlapping_bodies()
		for o in overlap:
			o.hit(99)
		next_track = load("res://Music/Music1.wav")
		track_progression_repeat = true
		$Boss.state = $Boss.State.ATTACK_UP
		$Boss.get_node("Timer").start()
		

func _start_button_released():
	if phase > 0:
		return
	start_button_pressed_count -= 1

func _on_crystal_collected(shard):
	if shard_num >= 8:
		shard.queue_free()
	else:
		shard_num += 1
		$Tween.interpolate_property(shard, "position", shard.position, get_node("ShardPos%d" % shard_num).position, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
	if shard_num >= 8:
		var explosions = get_tree().get_nodes_in_group("Explosions")
		for e in explosions:
			e.queue_free()
		$Tween.stop_all()
		$Boss.state = $Boss.State.STUN
		var shards = get_tree().get_nodes_in_group("Crystals")
		for s in shards:
			$Tween.interpolate_property(s, "position", s.position, $Boss.position, 1, Tween.TRANS_QUAD, Tween.EASE_IN, 1.5)
		$Tween.start()
		yield($Tween, "tween_completed")
		for s in shards:
			if weakref(s).get_ref():
				s.queue_free()
		$Boss.state = $Boss.State.VULNERABLE
		$Boss.vulnerable = true
		var skulls = get_tree().get_nodes_in_group("PhaseEnemies")
		for s in skulls:
			s.queue_free()
		if $Boss.target_ui != null and weakref($Boss.target_ui).get_ref():
			$Boss.target_ui.queue_free()
		shard_num = 0

func _spawn_button_pushed():
	if get_tree().get_nodes_in_group("PhaseEnemies").size() > 8:
		return
	call_deferred("_spawn_8_skulls")

func _spawn_8_skulls():
	var head_scn = load("res://Mobile/Skulltor/Skulltor.tscn")
	for j in range(2):
		for i in range(4):
			var head = head_scn.instance()
			head.drop_chance = 0.3
			var pos
			if j == 0:
				pos = $MidAreaL.position + Vector2(24, 0).rotated(randf() * 2 * PI)
			else:
				pos = $MidAreaR.position + Vector2(24, 0).rotated(randf() * 2 * PI)
			head.position = pos
			get_node("/root/Game").add_child(head)

func _debug_buttons():
	var button = load("res://Interactable/Button/Button.tscn")
	var topleftbutton = button.instance()
	var toprightbutton = button.instance()
	topleftbutton.position = $TopLeftButtonPos.position
	toprightbutton.position = $TopRightButtonPos.position
	get_node("/root/Game").add_child(topleftbutton)
	get_node("/root/Game").add_child(toprightbutton)
	topleftbutton.connect("pushed", get_node("/root/Game"), "_spawn_button_pushed")
	toprightbutton.connect("pushed", get_node("/root/Game"), "_spawn_button_pushed")

func _on_game_end():
	var map = load("res://Maps/Map3.tscn").instance()
	get_node("/root/Game").add_child(map)
	get_node("/root/Game/Map3Prime").queue_free()
	var button = load("res://Interactable/Button/Button.tscn").instance()
	button.position = $FinishButtonPos.position
	add_child(button)
	button.connect("pushed", self, "_end_game")

func _on_prime_end():
	var map = load("res://Maps/Map3Prime.tscn").instance()
	get_node("/root/Game").add_child(map)
	get_node("/root/Game/Map2").queue_free()

func _end_game():
	var explosion = load("res://Interactable/Explosion/ExplosionSide.tscn").instance()
	explosion.position = $FinishButtonPos.position
	add_child(explosion)
	yield(get_tree().create_timer(2), "timeout")
	explosion.queue_free()
	for p in get_tree().get_nodes_in_group("Players"):
		if weakref(p).get_ref():
			p.queue_free()
	get_node("Map3/Sprite").queue_free()
	$Tween.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, Color(0,0,0), 8, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property($CanvasLayer/VBoxContainer/CenterContainer/Label, "modulate", $CanvasLayer/VBoxContainer/CenterContainer/Label.modulate, Color(1,1,1,1), 8, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_MusicPlayer_finished():
	if next_track != null:
		$MusicPlayer.stream = next_track
		if next_track == preload("res://Music/Music1.wav"):
			if track_progression_repeat:
				track_progression_repeat = false
			else:
				next_track = load("res://Music/Music2.wav")
				track_progression_repeat = true
		elif next_track == preload("res://Music/Music2.wav"):
			if track_progression_repeat:
				track_progression_repeat = false
			else:
				next_track = load("res://Music/Music3.wav")
				track_progression_repeat = true
		elif next_track == preload("res://Music/Music3.wav"):
			next_track = load("res://Music/Music3to4.wav")
		elif next_track == preload("res://Music/Music3to4.wav"):
			next_track = load("res://Music/Music4.wav")
	if not end_music:
		$MusicPlayer.play()

func _on_MusicTimer_timeout():
	if next_track != null and next_track_immediate:
		$MusicPlayer.stream = next_track
		next_track = null
		next_track_immediate = false
