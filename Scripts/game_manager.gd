class_name GameManager extends Node

@onready var scene_executer : SceneExecuter = $"../SceneExecuter"

@export var current_event_id: String = "Scene_0"
var current_scene: Node

func _ready():
	load_event(current_event_id)
	scene_executer.connect("event_finished", Callable(self, "on_event_finished"))

func load_event(event_id: String):
	if current_scene: 
		current_scene.queue_free()
	
	var event_res_path = "res://Resources/%s.tres" % event_id
	if not ResourceLoader.exists(event_res_path):
		push_error("Event resource not found: " + event_res_path)
		return
	
	scene_executer.execute(load(event_res_path))

func on_event_finished(next_event_id: String):
	current_event_id = next_event_id
	load_event(next_event_id)
