class_name SceneExecuter extends Node

signal event_finished(next_event_id: String)

var background: BackgroundFader
var audio_player

var event_data: BaseEvent

func _init_refs() -> void:
	background = $"../Layer-Background/Background"
	audio_player = $AudioStreamPlayer2D

func execute(_event_data: BaseEvent):
	if(background == null):
		_init_refs()
	
	event_data = _event_data
	if event_data == null:
		push_error("No event_data to excute !")
		return

	if (event_data.music):
		audio_player.stream = event_data.music
		audio_player.play()
		print("Play music :", event_data.event_id)
		await audio_player.finished
	
	if (event_data.background):
		background.fade_to(event_data.background)
	
	show_choices()

func show_choices():
	print("Choose your next path:")
	#TO REMOVE LATER 
	for i in event_data.next_events.size():
		print(str(i + 1) + " : " + event_data.next_events[i])

func _input(event):
	#return #change with Wania code
	#if event.is_action_pressed((i)):
func _input(_event):
	#TO REMOVE LATER
	if Input.is_key_pressed(KEY_SPACE):
		var next_event = event_data.next_events[0]
		emit_signal("event_finished", next_event)
