extends HBoxContainer

@export var B1: Control
@export var B2: Control
@export var B3: Control
@export var B4: Control
@export var B: Control

@export var scene_executer: SceneExecuter
@export var input_handler: InputHandler


var buttons := []
var current_choices: Array[Scene] = []
var animating := false


func _ready():
	buttons = [B1, B2, B3, B4]
	hide_all()
	if scene_executer:
		scene_executer.scene_ready.connect(show_choices)
		print("Choice connecté à SceneExecuter.")
	else:
		push_warning("Aucun SceneExecuter assigné dans Choice.")
		
	if input_handler:
		input_handler.button_pressed.connect(_on_button_pressed)
		print("Choice connecté à InputHandler.")
	else:
		push_warning("Aucun InputHandler assigné à Choice.")

func hide_all():
	for b in buttons:
		b.visible = false
	B.visible = false


func show_choices():
	if animating:
			return
	animating = true

	input_handler.request_button_input()
	hide_all()

	if scene_executer == null or scene_executer.event_data == null:
		animating = false
		return
		
	current_choices = scene_executer.event_data.next_events
	var count = current_choices.size()
	if count == 0:
		animating = false
		return

	if count == 1:
		_animate_button(B, current_choices[0].icon, 0)
	else:
		for i in range(count):
			if i >= buttons.size():
				break
			_animate_button(buttons[i], current_choices[i].icon, i * 0.05)

	animating = false

func _animate_button(button: Control, icon: Texture, delay: float):
	var texture_rect = button.get_node("MarginContainer/TextureRect")
	texture_rect.texture = icon

	button.visible = true
	button.scale = Vector2(1, 1)
	var start_y = button.position.y + 100
	var end_y = button.position.y
	button.position.y = start_y

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(button, "position:y", end_y, 0.6)

func _on_button_pressed(button_name: String):
	if animating:
		return
	animating = true
	
	print("Bouton détecté dans Choice :", button_name)

	var index := -1
	match button_name:
		"button_1": index = 0
		"button_2": index = 1
		"button_3": index = 2
		"button_4": index = 3
		_: 
			print("Bouton inconnu :", button_name)
			animating = false
			return
	if scene_executer.event_data.next_events.size() == 1:
		index=0
	_hide_all_buttons()

	await get_tree().create_timer(0.6).timeout
	var next_event: Scene = current_choices[index]
	print("Scène choisie :", next_event.name)
	scene_executer.emit_signal("event_finished", next_event.name)
	animating = false

func _hide_all_buttons():
	var all_btns = []
	all_btns.append_array(buttons)
	all_btns.append(B)

	for i in range(all_btns.size()):
		var btn = all_btns[i]
		if not btn.visible:
			continue
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(btn, "position:y", btn.position.y + 120, 0.4)
		await tween.finished
		btn.visible = false
