extends Control
## Lobby screen: host a room, join one with a 4-digit code, or play solo.
## No online code here; it asks Net to do the work.

@onready var status_label: Label = $Box/Status
@onready var code_box: LineEdit = $Box/JoinRow/Code


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Box/Host.pressed.connect(Net.host_room)
	$Box/JoinRow/Join.pressed.connect(_on_join)
	code_box.text_submitted.connect(func(_t: String) -> void: _on_join())
	code_box.text_changed.connect(_only_digits)
	$Box/Solo.pressed.connect(_on_solo)
	$Box/Start.pressed.connect(Net.start_match)
	Net.status_changed.connect(_show_status)
	Net.room_changed.connect(_on_room_changed)
	_show_status(Net.status)
	$Box/Host.grab_focus() # So a gamepad can pick a button right away.


## In a room: the host gets "Start match", guests wait. Hide the other buttons.
func _on_room_changed() -> void:
	var in_room := Net.room_code != ""
	$Box/Host.visible = not in_room
	$Box/JoinRow.visible = not in_room
	$Box/Solo.visible = not in_room
	$Box/Start.visible = Net.in_room_as_host()
	if Net.in_room_as_host():
		$Box/Start.grab_focus()
	elif in_room:
		status_label.text += "\nWaiting for the host to start"


## Keep only the digits 0-9 in the code box.
func _only_digits(text: String) -> void:
	var digits := ""
	for c in text:
		if c >= "0" and c <= "9":
			digits += c
	if digits != text:
		code_box.text = digits
		code_box.caret_column = digits.length()


func _on_join() -> void:
	Net.join_room(code_box.text)


func _on_solo() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _show_status(text: String) -> void:
	status_label.text = text
