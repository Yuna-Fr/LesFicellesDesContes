extends Node2D

func _ready():
	_colorize_all(self, Color(1, 0, 0)) # Rouge

func _colorize_all(node: Node, color: Color):
	for child in node.get_children():
		if child is Sprite2D:
			child.modulate = color
		_colorize_all(child, color)
