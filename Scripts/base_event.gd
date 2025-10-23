class_name BaseEvent extends Resource

@export var description: String = "" # optional : for clarity

@export var music: AudioStream
@export var next_events: Array[Scene] = []
@export var movements: Array[Movement] = []
@export var characters_des: Array[String] = []
@export var characters_spawn: Array[CharacterAppear] = []
@export var spawns: Array[SpawnObject] = []
