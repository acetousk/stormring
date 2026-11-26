extends StaticBody3D
## A lunch box: stand close and hold the action button to open it.

var opened := false
var hold_time := 0.0
var player_near: Node3D = null

@onready var label: Label3D = $Label
@onready var lid: Node3D = $Lid


## A big tomato that floats and spins over a closed lunch box, so you can find it.
var sign_tomato: Node3D
var bob_time := randf() * TAU


func _ready() -> void:
	_make_sign()
	$Reach.body_entered.connect(_on_body_entered)
	$Reach.body_exited.connect(_on_body_exited)
	label.visible = false
	# Online: only the host may say I opened.
	Net.allow(_opened, true)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not opened:
		player_near = body
		label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body == player_near:
		player_near = null
		hold_time = 0.0
		label.visible = false


func _make_sign() -> void:
	sign_tomato = Node3D.new()
	add_child(sign_tomato)
	var fruit := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.45
	ball.height = 0.75
	ball.radial_segments = 12
	ball.rings = 6
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.902, 0.224, 0.275)
	red.emission_enabled = true # Glows a little, so you see it in the haze.
	red.emission = Color(0.902, 0.224, 0.275)
	red.emission_energy_multiplier = 0.35
	ball.material = red
	fruit.mesh = ball
	sign_tomato.add_child(fruit)
	var leaf := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.04
	cone.bottom_radius = 0.2
	cone.height = 0.14
	cone.radial_segments = 5
	cone.rings = 1
	var green := StandardMaterial3D.new()
	green.albedo_color = Color(0.655, 0.788, 0.341) # Jello green from the palette
	cone.material = green
	leaf.mesh = cone
	leaf.position.y = 0.38
	sign_tomato.add_child(leaf)
	for part in [fruit, leaf]:
		part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _process(delta: float) -> void:
	# The sign bobs up and down and spins while the box is closed.
	bob_time += delta
	sign_tomato.visible = not opened
	sign_tomato.position = Vector3(0, 2.2 + 0.25 * sin(bob_time * 2.0), 0)
	sign_tomato.rotation.y = bob_time * 1.2
	if opened or player_near == null:
		return
	# Holding fills up the timer; letting go resets it.
	if Input.is_action_pressed("action"):
		hold_time += delta
	else:
		hold_time = 0.0
	var bars := int(hold_time / Tune.chest_open_time * 10.0)
	label.text = "Hold E" if hold_time == 0.0 else "[" + "|".repeat(bars) + " ".repeat(10 - bars) + "]"
	if hold_time >= Tune.chest_open_time:
		hold_time = 0.0
		Net.tell_host(_ask_open, Net.my_id())


## Runs on the host: the first person to ask gets the lunch box.
func _ask_open(by_id: int) -> void:
	if opened:
		return
	Net.tell_everyone(_opened, by_id)


## Runs on every screen: the lid comes off. The person who opened it gets tomatoes and a napkin.
func _opened(by_id: int) -> void:
	opened = true
	label.visible = false
	lid.visible = false
	var me := get_tree().get_first_node_in_group("player")
	if by_id == Net.my_id() and me:
		me.give_loot()
