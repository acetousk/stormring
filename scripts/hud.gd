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


const FEED_STAY := 5.0 ## Seconds a line stays in the splat feed
const FEED_MOST := 4 ## Most lines in the splat feed at once
const TOMATO := Color(0.902, 0.224, 0.275)
const CREAM := Color(1, 0.945, 0.839)
const DARK := Color(0.149, 0.275, 0.325)

## The splat feed in the top left: "Max splatted Rosa".
var feed_box: VBoxContainer
## Red tomato blobs on the screen when you get hit. They fade out.
var mess: Control
var mess_left := 0.0
## The "Splat!" mark around the crosshair when your tomato hits someone.
var marker: Label
var marker_left := 0.0


func _ready() -> void:
	end_box.visible = false
	warning.visible = false
	_make_feed()
	_make_mess()
	_make_marker()


func _make_feed() -> void:
	feed_box = VBoxContainer.new()
	feed_box.position = Vector2(24, 72)
	feed_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(feed_box)


## A new line in the splat feed. Your own lines are tomato red.
func feed(text: String, mine: bool) -> void:
	var line := Label.new()
	line.text = text
	var look := LabelSettings.new()
	look.font_size = 24
	look.font_color = TOMATO if mine else CREAM
	look.outline_size = 6
	look.outline_color = DARK
	line.label_settings = look
	feed_box.add_child(line)
	if feed_box.get_child_count() > FEED_MOST:
		feed_box.get_child(0).queue_free()
	get_tree().create_timer(FEED_STAY).timeout.connect(line.queue_free)


func _make_mess() -> void:
	mess = Control.new()
	mess.set_anchors_preset(Control.PRESET_FULL_RECT)
	mess.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mess.draw.connect(_draw_mess)
	add_child(mess)
	move_child(mess, 0) # Behind the cards and the report card.


## Which screen edge the last tomato came from: 0 left, 1 right, 2 top, 3 bottom (-1 = any).
var mess_edge := -1


## A tomato hit you, thrown from `from`: the mess goes on that side of the screen,
## so you know where to look.
func hit_from(from: Vector3) -> void:
	tomato_hit_at = Time.get_ticks_msec()
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var local := cam.global_transform.affine_inverse() * from
	if local.z > 0.0 and absf(local.x) < local.z:
		mess_edge = 3 # Behind you: the bottom edge.
	elif absf(local.x) > absf(local.y):
		mess_edge = 1 if local.x > 0.0 else 0
	else:
		mess_edge = 2 if local.y > 0.0 else 3


## When a tomato last hit you (ms). The jello also takes clean away, but it is not a tomato.
var tomato_hit_at := -10000


## A tomato hit you: red blobs near the screen edge, bigger for a bigger hit.
func ouch(amount: float) -> void:
	# Only tomatoes make a mess on the screen (the jello has its own red slip).
	# Online, the new clean comes from the host a little after the tomato lands.
	if end_box.visible or Time.get_ticks_msec() - tomato_hit_at > 700:
		return
	mess_left = clampf(mess_left + amount / 25.0, 0.4, 1.0)
	mess.set_meta("seed", randi())
	Sfx.play_here("ouch")


func _draw_mess() -> void:
	if mess_left <= 0.0:
		return
	var size := mess.size
	var rng := RandomNumberGenerator.new()
	rng.seed = mess.get_meta("seed", 1)
	var color := TOMATO
	color.a = 0.55 * mess_left
	# 6 blobs near the edges, so the middle (where you aim) stays clear.
	for i in 6:
		# Most blobs go on the side the tomato came from.
		var edge := mess_edge if mess_edge >= 0 and i < 5 else rng.randi_range(0, 3)
		var spot := Vector2(rng.randf() * size.x, rng.randf() * size.y)
		match edge:
			0: spot.x = rng.randf() * size.x * 0.18
			1: spot.x = size.x - rng.randf() * size.x * 0.18
			2: spot.y = rng.randf() * size.y * 0.18
			3: spot.y = size.y - rng.randf() * size.y * 0.18
		var r := rng.randf_range(40.0, 90.0)
		mess.draw_circle(spot, r, color)
		for d in 4:
			var drop := spot + Vector2.from_angle(rng.randf() * TAU) * r * rng.randf_range(1.1, 1.6)
			mess.draw_circle(drop, r * rng.randf_range(0.12, 0.25), color)


## The arrow under the red slip: which way to run to get out of the jello.
var arrow: Control


## Outside the circle: the arrow under the red slip points to the safe middle, with meters to go.
func _point_to_safe(storm: Node, player: Node3D) -> void:
	if arrow == null:
		arrow = Control.new()
		arrow.draw.connect(_draw_arrow)
		# Under the middle of the red slip.
		arrow.anchor_left = 0.5
		arrow.anchor_right = 0.5
		arrow.offset_left = -40
		arrow.offset_right = 40
		arrow.offset_top = 236
		arrow.offset_bottom = 316
		arrow.pivot_offset = Vector2(40, 40)
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(arrow)
	arrow.visible = warning.visible
	if not warning.visible:
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var to := Vector3(storm.center.x, 0, storm.center.y) - player.global_position
	# Flat directions on the floor, so looking up or down does not bend the arrow.
	var forward := Vector2(-cam.global_basis.z.x, -cam.global_basis.z.z).normalized()
	var right := Vector2(cam.global_basis.x.x, cam.global_basis.x.z).normalized()
	var flat := Vector2(to.x, to.z)
	# The angle from where you look to where the middle is (0 = straight ahead, + = to the right).
	arrow.rotation = atan2(flat.dot(right), flat.dot(forward))
	var meters := maxf(Vector2(to.x, to.z).length() - storm.radius, 0.0)
	$StormWarning/Text.text = "Get out of the jello spill! %d m" % ceili(meters)


## An arrow pointing up (the Control turns it): a cream outline, tomato inside.
func _draw_arrow() -> void:
	var tip := [Vector2(40, 4), Vector2(72, 40), Vector2(52, 40), Vector2(52, 76), Vector2(28, 76), Vector2(28, 40), Vector2(8, 40)]
	var outline := PackedVector2Array(tip)
	arrow.draw_colored_polygon(outline, TOMATO)
	outline.append(tip[0])
	arrow.draw_polyline(outline, CREAM, 4.0)


## One short tip at the top for new players. It goes away once you know the step.
var coach: Label
var threw_once := false
var wiped_once := false
## Seconds left to show the tray wall tip (once, after your first throw).
var tray_tip_left := -1.0


func _coach(player: Node3D) -> void:
	if coach == null:
		coach = Label.new()
		var look := LabelSettings.new()
		look.font_size = 28
		look.font_color = CREAM
		look.outline_size = 8
		look.outline_color = DARK
		coach.label_settings = look
		coach.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		coach.anchor_left = 0.5
		coach.anchor_right = 0.5
		# Under the top corner labels, where the red slip goes (they never show at once).
		coach.offset_left = -320
		coach.offset_right = 320
		coach.offset_top = 120
		coach.offset_bottom = 200
		coach.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		coach.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(coach)
	var touch := TouchControls.is_on()
	var tip := ""
	if end_box.visible or player.is_out:
		tip = ""
	elif warning.visible:
		tip = "" # The red slip already says what to do.
	elif player.global_position.y > 4.0 and player.is_on_floor() and not player.has_tomatoes:
		tip = "Jump off the table! Your napkin opens on the way down."
	elif not player.has_tomatoes:
		tip = "Find a lunch box: look for a floating tomato." + ("" if touch else " Hold E to open it.")
	elif not threw_once and player.slot == 2:
		threw_once = player.tomatoes < Tune.tomato_bag
		if threw_once:
			tray_tip_left = 8.0
		else:
			tip = ("Tap THROW to throw." if touch else "Click to throw. Hold right click to aim.")
	elif not wiped_once and player.napkins > 0 and player.hp < Tune.max_hp * 0.6:
		wiped_once = player.wipe_left > 0.0
		if not wiped_once:
			tip = "You're messy! " + ("Tap WIPE to use a napkin." if touch else "Press H to wipe with a napkin.")
	elif tray_tip_left > 0.0:
		tray_tip_left -= get_process_delta_time()
		tip = "Need cover? " + ("Hit a tray cart to get trays, then tap BUILD." if touch \
				else "Press 1 for the spoon and hit a tray cart. Then Q builds a tray wall.")
	coach.text = tip
	coach.visible = tip != ""


func _make_marker() -> void:
	marker = Label.new()
	marker.text = "Splat!"
	var look := LabelSettings.new()
	look.font_size = 30
	look.font_color = TOMATO
	look.outline_size = 8
	look.outline_color = CREAM
	marker.label_settings = look
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.set_anchors_preset(Control.PRESET_CENTER)
	marker.position = Vector2(-60, -70)
	marker.size = Vector2(120, 40)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.visible = false
	$Crosshair.add_child(marker)


## Your tomato hit someone: "Splat!" over the crosshair, and the crosshair turns red.
func hit_marker() -> void:
	marker_left = 0.45


func _tick_effects(delta: float) -> void:
	if mess_left > 0.0:
		mess_left = maxf(mess_left - delta * 0.6, 0.0)
		mess.queue_redraw()
	marker_left = maxf(marker_left - delta, 0.0)
	marker.visible = marker_left > 0.0
	# Pop: a bit bigger at first, then normal size.
	marker.scale = Vector2.ONE * (1.0 + marker_left)
	marker.pivot_offset = marker.size / 2.0
	for part in $Crosshair.get_children():
		if part is ColorRect:
			part.color = TOMATO if marker_left > 0.0 else CREAM


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
	var won := title == "Last one clean!"
	$End/Box/Grades/Title.text = title
	# A win always gets an A+. The stats still say how clean you stayed.
	$End/Box/Grades/Grade.text = "A+" if won else grade_for(percent)
	$End/Box/Stats.text = stats + ("   Clean %d%%" % percent if won else "")
	$End/Box/Hint.text = hint
	$End/Star.visible = won
	end_box.visible = true
	# Only the report card now: hide the cards and the slip behind it.
	for part in [$Grade, $Pocket, warning, $Crosshair]:
		part.visible = false


## The words on the report card now (the host uses them to show a new hint).
func end_title() -> String:
	return $End/Box/Grades/Title.text


func end_stats() -> String:
	return $End/Box/Stats.text


func _process(delta: float) -> void:
	_tick_effects(delta)
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
		_point_to_safe(storm, player)
	if player == null:
		return
	_coach(player)
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
