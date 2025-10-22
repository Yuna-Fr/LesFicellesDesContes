class_name BaseEvent extends Resource

@export var description: String = "" # optional : for clarity

@export var music: AudioStream
@export var next_events: Array[String] = []
@export var movements: Array[Movement] = []
@export var spawns: Array[SpawnObject] = []
