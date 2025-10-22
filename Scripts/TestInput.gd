extends Node

@onready var inputHandler : InputHandler = $"../InputHandler"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hello")
	inputHandler.button_pressed.connect(_on_button_pressed)



func _input(event):
	if event.is_action_pressed("wantButton"):
		inputHandler.request_button_input() 

func _on_button_pressed(button_name: String):
	print("Bouton détecté dans le test :", button_name)
