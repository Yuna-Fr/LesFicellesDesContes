class_name SceneExecuter extends Node

signal event_finished(next_event_id: String)
signal scene_ready


var movements_finished : bool = false
var spawns_finished : bool = false
var waiting_for_scene : bool = false



var active_movements: Array = []
var active_tweens = 0
var active_objects: Dictionary = {}


@export var music_fade_time : float = 2.0
@export var positions_root : Node

var background: BackgroundFader
var audio_player
var music_player_a
var music_player_b
var event_data: BaseEvent
#region General

func _init_refs() -> void:
	#inputHandler = $"../InputHandler"
	background = $"../Layer-Background/Background"
	audio_player = $AudioPlayer
	music_player_a = $MusicPlayerA
	music_player_b = $MusicPlayerB
	#inputHandler.button_pressed.connect(_on_rope_pulled)

'''Characters'''
@export var Kat : Node2D
@export var BB : Node2D
@export var Anne : Node2D
@export var Mom : Node2D
@export var Girls : Node2D
@export var Dead : Node2D
@export var Brother : Node2D



func execute(_event_data: BaseEvent):
	if(background == null): _init_refs()
	
	event_data = _event_data
	movements_finished = false
	spawns_finished = false
	waiting_for_scene = false

	
	if event_data == null:
		push_error("No event_data to excute !")
		return
	
	remove_unused_objects(event_data.spawns)
	start_movements(event_data.movements)
	spawn_objects(event_data.spawns)
	
	if (event_data.background): background.fade_to(event_data.background)
	
	if (event_data.music): _play_music(event_data.music)
	
	if event_data.dialogues.size() > 0:
		for dialogue in event_data.dialogues: 
			print(dialogue) 
			if dialogue.sound:
				audio_player.stream = dialogue.sound
				audio_player.play()
				await audio_player.finished
				
			if dialogue.delay_after_sound > 0:
				await get_tree().create_timer(dialogue.delay_after_sound).timeout

	# _show_choices()
	


func _process(delta):
	if(movements_finished && spawns_finished):
		if not waiting_for_scene:
			waiting_for_scene = true
			emit_signal("scene_ready")
		return
	process_movements(delta)
	
func spawn_objects(spawn_list: Array[SpawnObject]):
	var viewport_size = get_viewport().size
	var z_offsets = {}

	for spawn in spawn_list:
		if not positions_root.has_node(spawn.target):
			push_warning("Target node not found: " + str(spawn.target))
			continue

		var obj_node: Node2D = positions_root.get_node(spawn.target)
		if active_objects.has(obj_node.name):
			continue # déjà présent, on ne fait rien

		active_objects[obj_node.name] = true

		var final_pos = obj_node.global_position
		var offset = get_direction(spawn.direction)
		obj_node.global_position = final_pos + offset
		obj_node.visible = true

		var z_key = obj_node.z_index
		var same_z_count = z_offsets.get(z_key, 0)
		z_offsets[z_key] = same_z_count + 1

		var base_delay = z_key * 0.05
		var extra_delay = same_z_count * 0.03
		var total_delay = base_delay + extra_delay

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		active_tweens += 1
		tween.tween_property(obj_node, "global_position", final_pos, 0.5).set_delay(total_delay)
		tween.finished.connect(Callable(self, "_on_single_spawn_finished"))


func remove_unused_objects(new_spawn_list: Array[SpawnObject]):
	if active_objects.is_empty():
		return
	var new_targets: Dictionary = {}
	for spawn in new_spawn_list:
		new_targets[spawn.target] = true

	for obj_node in active_objects:
		if not obj_node is Node2D:
			continue
		if new_targets.has(obj_node.name):
			continue # on garde

		if obj_node.visible:
			var final_pos = obj_node.global_position + Vector2(0, get_viewport().size.y)
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_OUT)
			active_tweens += 1
			tween.tween_property(obj_node, "global_position", final_pos, 0.5)
			tween.finished.connect(Callable(self, "_on_single_spawn_finished"))
			active_objects.erase(obj_node.name)
			obj_node.visible = false

func get_direction(direction_name: String) -> Vector2:
	var viewport_size = get_viewport().size
	print(viewport_size)
	match direction_name:
		"haut": return Vector2(0, -viewport_size.y)
		"bas": return Vector2(0, viewport_size.y)
		"gauche": return Vector2(-viewport_size.x, 0)
		"droite": return Vector2(viewport_size.x, 0)
		_: return Vector2.ZERO

		

func _on_single_spawn_finished():
	active_tweens -= 1
	if active_tweens <= 0:
		print("Tous est affiché")
		spawns_finished = true

func start_movements(movements: Array[Movement]):
	active_movements.clear()
	for move in movements:
		var char_node = get_character_node(move.character)
		if not char_node:
			push_warning("Character not found: " + move.character)
			continue

		var target_node = positions_root.get_node(move.target)
		if not target_node:
			push_warning("Target not found: " + str(move.target))
			continue

		active_movements.append({
			"node": char_node,
			"target": target_node.position,
			"speed": move.vitesse
		})

func process_movements(delta):
	if active_movements.is_empty():
		return

	var finished = []

	for move in active_movements:
		var node: Node2D = move["node"]
		var target: Vector2 = move["target"]
		var speed: float = move["speed"]
		var real_speed = speed * 2.0

		node.global_position = node.global_position.move_toward(target, real_speed * delta)

		if not move.has("sprite"):
			var sprite = node.get_child(0)
			move["sprite"] = sprite
			move["base_y"] = sprite.position.y
			move["time"] = 0.0

		var sprite = move["sprite"]
		if sprite:
			var direction_x = target.x - node.global_position.x
			if abs(direction_x) > 1.0:
				sprite.flip_h = direction_x < 0

			var amplitude = clamp(speed * 0.35, 5.0, 20.0)
			var frequency = clamp(speed * 0.2, 1.0, 3.0)
			move["time"] += delta * frequency
			sprite.position.y = move["base_y"] + sin(move["time"] * TAU) * amplitude

		if node.global_position.distance_to(target) < 1.0:
			node.global_position = target
			finished.append(move)

	for done in finished:
		active_movements.erase(done)

	if active_movements.is_empty():
		movements_finished = true
	
func get_character_node(character_name: String) -> Node2D:
	match character_name:
		"Kat": return Kat
		"BB": return BB
		"Anne": return Anne
		"Mom": return Mom
		"Girls": return Girls
		"Dead": return Dead
		"Brother": return Brother
		_: return null

func _show_choices():
	print("Choose your next path:")
	#inputHandler.request_button_input() 
	#TO REMOVE LATER 
#func _on_rope_pulled(button_name: String):
	#print("Bouton détecté dans le test :", button_name)
	#var next_event = event_data.next_events[0]
	#emit_signal("event_finished", next_event)

#endregion

#region Sounds

var current_music_player : AudioStreamPlayer
var next_music_player : AudioStreamPlayer

func _play_music(new_stream: AudioStream):
	if current_music_player.stream == new_stream: return  # same track, no need to fade

	next_music_player.stream = new_stream
	next_music_player.volume_db = -80
	next_music_player.play()

	var tween = create_tween()
	tween.tween_property(current_music_player, "volume_db", -80, music_fade_time)
	tween.parallel().tween_property(next_music_player, "volume_db", 0, music_fade_time)

	tween.tween_callback(Callable(self, "_swap_music_players"))

func _swap_music_players():
	current_music_player.stop()
	var temp = current_music_player
	current_music_player = next_music_player
	next_music_player = temp

#endregion
