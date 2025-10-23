class_name BaseEvent extends Resource

@export var description: String = "" # optional : for clarity

@export var background: GradientTexture2D
@export var music: AudioStream
@export var dialogues: Array[Dialogue] = []

@export var next_events: Array[String] = []
