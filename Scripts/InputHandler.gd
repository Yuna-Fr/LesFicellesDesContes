class_name InputHandler
extends Node

signal button_pressed(button_name: String)

var serial: GdSerial
var is_connected := false
var current_button := ""
var waiting_for_button := false

func _ready() -> void:
	serial = GdSerial.new()
	serial.set_port("COM5")
	serial.set_baud_rate(115200)

	if serial.open():
		print("ESP connectée")
		is_connected = true
	else:
		push_error("Impossible de se connecter")
		is_connected = false

func _process(delta: float) -> void:
	if not is_connected:
		return

	monitor_serial()

func request_button_input() -> void:
	if not is_connected:
		push_warning("Pas de connexion")
		return

	if waiting_for_button:
		push_warning("Déjà en attente d’un bouton")
		return

	var request = {"getButton": true}
	var msg = JSON.stringify(request)
	serial.write_string(msg + "\n")
	waiting_for_button = true
	print("Demande d’input bouton envoyée")
	
func monitor_serial() -> void:
	var bytes = serial.bytes_available()
	if bytes <= 0:
		return

	var data = serial.readline()
	data = data.strip_edges()

	if data == "":
		return

	var json := JSON.new()
	if json.parse(data) != OK:
		push_warning("JSON invalide reçu : " + data)
		return

	var obj = json.get_data()
	if obj.has("type") and obj["type"] == "button_state":
		current_button = obj["pressed"]
		print("Bouton détecté : ", current_button)
		emit_signal("button_pressed", current_button)
		send_ack()
		waiting_for_button = false
		
func send_ack() -> void:
	var ack = {"ack": true}
	serial.write_string(JSON.stringify(ack) + "\n")
	print("ACK envoyé")

func get_last_button() -> String:
	return current_button

func _exit_tree() -> void:
	if is_connected:
		serial.close()
