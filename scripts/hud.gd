extends CanvasLayer
## The HUD, in the style of an 80s school: a grade card for how clean you are,
## an index card for what is in your pockets, a red slip when you stand in the
## jello spill, and a report card at the end.

## The grade for how clean you are, best first: [lowest clean %, letter].
const GRADES := [[97, "A+"], [90, "A"], [80, "B"], [70, "C"], [60, "D"], [0, "F"]]

@onready var hp_label: Label = $Grade/Row/Col/HP
@onready var letter_label: Label = $Grade/Row/Letter
@onready var ammo_label: Label = $Pocket/Col/Ammo
@onready var heal_label: Label = $Pocket/Col/Heals
@onready var left_label: Label = $Left
@onready var end_box: Control = $End
@onready var storm_label: Label = $StormTimer
@onready var warning: Control = $StormWarning


func _ready() -> void:
	end_box.visible = false
	warning.visible = false


## The letter grade for a clean percent (100 = A+, under 60 = F).
static func grade_for(percent: int) -> String:
	for g in GRADES:
		if percent >= g[0]:
			return g[1]
	return "F"


## Show the report card at the end of the match. A win gets a gold star.
func show_end(title: String, stats: String, hint: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	var percent := ceili(player.hp / Tune.max_hp * 100.0) if player else 0
	$End/Box/Grades/Title.text = title
	$End/Box/Grades/Grade.text = grade_for(percent)
	$End/Box/Stats.text = stats
	$End/Box/Hint.text = hint
	$End/Star.visible = title == "Last one clean!"
	end_box.visible = true
	# Only the report card now: hide the cards and the slip behind it.
	for part in [$Grade, $Pocket, warning, $Crosshair]:
		part.visible = false


## The words on the report card now (the host uses them to show a new hint).
func end_title() -> String:
	return $End/Box/Grades/Title.text


func end_stats() -> String:
	return $End/Box/Stats.text


func _process(_delta: float) -> void:
	# Everyone still in the match is in the "fighter" group.
	left_label.text = "Kids left %d" % get_tree().get_nodes_in_group("fighter").size()
	# Online status: only in online matches (solo does not need the network).
	$NetStatus.visible = Net.online
	$NetStatus.text = Net.status

	# Jello spill clock, and the red slip when you stand outside the circle.
	var storm := get_tree().get_first_node_in_group("storm")
	var player := get_tree().get_first_node_in_group("player")
	if storm:
		var secs := ceili(storm.time_left())
		var clock := "%d:%02d" % [floori(secs / 60.0), secs % 60]
		storm_label.text = ("Jello spill spreading " if storm.shrinking else "Jello spill in ") + clock
		warning.visible = player != null and not player.is_out and not end_box.visible \
				and not storm.is_safe(player.global_position)
	if player == null:
		return
	var percent := ceili(player.hp / Tune.max_hp * 100.0)
	letter_label.text = grade_for(percent)
	hp_label.text = "%d%%" % percent
	if player.wipe_left > 0.0:
		hp_label.text += " wiping..."
	# What is in your hand.
	var food_text := "[2] Tomatoes" if player.has_tomatoes else "[2] empty: open a lunch box"
	if player.slot == 1:
		ammo_label.text = "> [1] Spoon   " + food_text
	elif player.refilling:
		ammo_label.text = "[1] Spoon   > [2] Grabbing tomatoes..."
	else:
		ammo_label.text = "[1] Spoon   > [2] Tomatoes  %d / %d" % [player.tomatoes, Tune.tomato_bag]
	heal_label.text = "Trays  %d   Napkins  %d" % [player.trays, player.napkins]
