class_name SceneExecuter extends Node

signal event_finished(next_event_id: String)

#var inputHandler : InputHandler
@export var music_fade_time : float = 2.0

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

func execute(_event_data: BaseEvent):
	if(background == null): _init_refs()
	
	event_data = _event_data
	if event_data == null:
		push_error("No event_data to excute !")
		return
	
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
	
	_show_choices()

func _show_choices():
	print("Choose your next path:")
	#inputHandler.request_button_input() 
	#TO REMOVE LATER 
	for i in event_data.next_events.size():
		print(str(i + 1) + " : " + event_data.next_events[i])

func _input(_event):
	#TO REMOVE LATER
	if Input.is_key_pressed(KEY_SPACE):
		var next_event = event_data.next_events[0]
		emit_signal("event_finished", next_event)
		

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
