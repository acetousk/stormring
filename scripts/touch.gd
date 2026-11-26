class_name TouchControls
extends Control
## On-screen controls for phones and tablets.
## They press the same Input Map actions as the keyboard and gamepad,
## so the player script does not care where a press came from.
## Shown only on touch screens, or on your PC when Tune.force_touch is on
## (then the mouse acts like one finger).

const FAINT := Color(0.914, 0.769, 0.416, 0.25) ## Sand, see-through
const LINE := Color(0.914, 0.769, 0.416, 0.6)

## Left thumb stick: where it sits and how far the knob can go.
const STICK_SPOT := Vector2(200, -200) ## From the bottom-left corner
const STICK_RADIUS := 110.0


## True if touch controls are on for this device.
static func is_on() -> bool:
	return Tune.force_touch or DisplayServer.is_touchscreen_available()


func _ready() -> void:
	visible = is_on()
	mouse_filter = Control.MOUSE_FILTER_IGNORE # Never block the end screen or menus.
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if visible:
		_unhook_mouse_buttons()
	if Tune.force_touch:
		Input.emulate_touch_from_mouse = true # PC test: the mouse is your finger.


var _mouse_events := {} ## action → the mouse-button events we took away


## A tap also counts as a mouse click, and a mouse click fires the rifle.
## With touch controls, only the on-screen buttons should do that.
func _unhook_mouse_buttons() -> void:
	for action in InputMap.get_actions():
		for e in InputMap.action_get_events(action):
			if e is InputEventMouseButton and not String(action).begins_with("ui_"):
				_mouse_events.get_or_add(action, []).append(e)
				InputMap.action_erase_event(action, e)


## The 5 buttons: label, the action it presses, spot from the bottom-right corner, size.
const BUTTONS := [
	{"text": "FIRE", "action": "fire", "spot": Vector2(-180, -240), "radius": 80.0},
	{"text": "JUMP", "action": "jump", "spot": Vector2(-340, -110), "radius": 55.0},
	{"text": "BUILD", "action": "build", "spot": Vector2(-90, -420), "radius": 50.0},
	{"text": "USE", "action": "action", "spot": Vector2(-300, -300), "radius": 50.0},
	{"text": "HEAL", "action": "heal", "spot": Vector2(-80, -90), "radius": 45.0},
]
const HELD := Color(0.914, 0.769, 0.416, 0.55) ## A button while your finger is on it

var button_fingers := {} ## finger → the button it holds
var stick_finger := -1 ## Which finger holds the stick (-1 = none)
var look_finger := -1 ## Which finger drags to look (-1 = none)
var knob := Vector2.ZERO ## How far the knob is pushed (length 0 to 1)


func _stick_center() -> Vector2:
	return Vector2(STICK_SPOT.x, size.y + STICK_SPOT.y)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		var button := _button_at(event.position)
		if event.pressed and not button.is_empty():
			button_fingers[event.index] = button # Buttons first: hold = action held.
			Input.action_press(button.action)
			queue_redraw()
		elif not event.pressed and button_fingers.has(event.index):
			Input.action_release(button_fingers[event.index].action)
			button_fingers.erase(event.index)
			queue_redraw()
		elif event.pressed and stick_finger == -1 \
				and event.position.distance_to(_stick_center()) < STICK_RADIUS * 1.5:
			stick_finger = event.index # A finger landed on the stick.
			_move_knob(event.position)
		elif event.pressed and look_finger == -1 and event.position.x > size.x / 2.0:
			look_finger = event.index # A finger landed on the right side: look.
		elif not event.pressed and event.index == stick_finger:
			stick_finger = -1 # Finger lifted: let go of the stick.
			_move_knob(_stick_center())
		elif not event.pressed and event.index == look_finger:
			look_finger = -1
	elif event is InputEventScreenDrag:
		if event.index == stick_finger:
			_move_knob(event.position)
		elif event.index == look_finger:
			# Turn your view the way you drag, like the mouse does.
			var me := get_tree().get_first_node_in_group("player")
			if me:
				me._look(-event.relative * Tune.touch_look_speed)


## Put the knob under the finger (but not past the ring) and press the
## move actions as hard as it is pushed, like a gamepad stick.
func _move_knob(finger: Vector2) -> void:
	knob = ((finger - _stick_center()) / STICK_RADIUS).limit_length(1.0)
	_press("move_right", maxf(knob.x, 0.0))
	_press("move_left", maxf(-knob.x, 0.0))
	_press("move_back", maxf(knob.y, 0.0))
	_press("move_forward", maxf(-knob.y, 0.0))
	queue_redraw()


func _button_spot(b: Dictionary) -> Vector2:
	return size + b.spot


## The button under a finger, or {} if none.
func _button_at(spot: Vector2) -> Dictionary:
	for b in BUTTONS:
		if spot.distance_to(_button_spot(b)) <= b.radius:
			return b
	return {}


func _press(action: String, strength: float) -> void:
	if strength > 0.05:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _exit_tree() -> void:
	_move_knob(_stick_center()) # Match over: let go of everything.
	for b in button_fingers.values():
		Input.action_release(b.action)
	for action in _mouse_events: # Give the mouse buttons back.
		for e in _mouse_events[action]:
			InputMap.action_add_event(action, e)


func _draw() -> void:
	# The stick's ring, and the knob where your thumb pushes it.
	draw_circle(_stick_center(), STICK_RADIUS, FAINT)
	draw_arc(_stick_center(), STICK_RADIUS, 0.0, TAU, 48, LINE, 3.0)
	draw_circle(_stick_center() + knob * STICK_RADIUS, STICK_RADIUS * 0.4, LINE)
	# The buttons, brighter while held, with their name in the middle.
	var font := ThemeDB.fallback_font
	var held := button_fingers.values()
	for b in BUTTONS:
		var spot := _button_spot(b)
		draw_circle(spot, b.radius, HELD if held.has(b) else FAINT)
		draw_arc(spot, b.radius, 0.0, TAU, 40, LINE, 3.0)
		var font_size := 22 if b.radius > 50.0 else 18
		var w := font.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, spot + Vector2(-w / 2.0, font_size * 0.35), b.text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.149, 0.275, 0.325))
