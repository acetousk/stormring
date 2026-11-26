extends StaticBody3D
## A chest: stand close and hold the action button to open it.

var opened := false
var hold_time := 0.0
var player_near: Node3D = null

@onready var label: Label3D = $Label
@onready var lid: MeshInstance3D = $Lid


func _ready() -> void:
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


func _process(delta: float) -> void:
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


## Runs on the host: the first person to ask gets the chest.
func _ask_open(by_id: int) -> void:
	if opened:
		return
	Net.tell_everyone(_opened, by_id)


## Runs on every screen: the lid goes away. The person who opened it gets the loot.
func _opened(by_id: int) -> void:
	opened = true
	label.visible = false
	lid.visible = false
	var me := get_tree().get_first_node_in_group("player")
	if by_id == Net.my_id() and me:
		me.give_loot()
