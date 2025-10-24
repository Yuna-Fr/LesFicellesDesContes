class_name BaseEvent extends Resource

@export var description: String = "" # optional : for clarity

@export var background: GradientTexture2D

@export var music: MusicName = MusicName.None
@export var dialogues: Array[Dialogue] = []

@export var movements: Array[Movement] = []
@export var characters_des: Array[String] = []
@export var characters_spawn: Array[CharacterAppear] = []
@export var spawns: Array[SpawnObject] = []

@export var next_events: Array[Scene] = []

enum MusicName { None, Onirique, Revelation, Soulagement, Tension, Violin }     
