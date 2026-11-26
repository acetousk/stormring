extends Node
## Net test robot. tools/net_test.py starts two copies of the game with:
##   --net-test=host --code=1234     or     --net-test=join --code=1234
## 1. The host makes the room and starts the match when the joiner is in.
## 2. The joiner does things by itself: opens a chest, builds a wall, shoots a bot.
## 3. At 10, 30 and 60 s (storm clock, same on both) each copy prints what it sees.
## Every line that starts with "NETTEST:" is read by net_test.py.

const SNAP_TIMES := [10.0, 30.0, 60.0]
## Joiner actions: seconds after the joiner's match started.
const CHEST_AT := 12.0
const WALL_AT := 14.0
const SHOOT_AT := 16.0
const WALL_SPOT := Vector3(10, 2.2, 10)

var role := ""
var code := ""
var seconds := 120.0 ## Quit after this long, no matter what.
var clock := 0.0
var match_clock := -1.0 ## Seconds since the match started here (-1 = not yet)
var join_retry := 0.0
var host_sent := false
var start_sent := false
var snaps_done := 0
var actions_done := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--net-test="):
			role = arg.get_slice("=", 1)
		elif arg.begins_with("--code="):
			code = arg.get_slice("=", 1)
		elif arg.begins_with("--seconds="):
			seconds = float(arg.get_slice("=", 1))
	say("role %s code %s" % [role, code])
	Net.status_changed.connect(func(t: String) -> void: say("status " + t))
	GDSync.change_scene_success.connect(_on_match_started)


func say(text: String) -> void:
	print("NETTEST: ", text)


func _on_match_started(_path: String) -> void:
	match_clock = 0.0
	say("match started")
	say("my id %d, host id %d" % [GDSync.get_client_id(), GDSync.get_host()])


func _process(delta: float) -> void:
	clock += delta
	if clock > seconds:
		say("timeout")
		get_tree().quit()
		return
	if not Net.connected:
		return
	if match_clock < 0.0:
		_get_into_match(delta)
		return

	match_clock += delta
	if role == "join":
		_joiner_actions()
	_snapshots()


## Step 1: host makes the room and starts; joiner keeps trying to join.
func _get_into_match(delta: float) -> void:
	if role == "host":
		if Net.room_code == "" and not host_sent:
			host_sent = true
			Net.host_room(code)
		elif Net.in_room_as_host() and Net.player_count() >= 2 and not start_sent:
			start_sent = true
			say("joiner is in, starting")
			Net.start_match()
	elif role == "join" and Net.room_code == "":
		# GD-Sync looks for the room for about 5 seconds per try.
		join_retry -= delta
		if join_retry <= 0.0:
			join_retry = 7.0
			Net.join_room(code)


## Step 2: the joiner opens a chest, builds a wall, and shoots a bot.
func _joiner_actions() -> void:
	var tree := get_tree()
	var me: Node = tree.get_first_node_in_group("player")
	if me == null:
		if actions_done == 0 and match_clock >= CHEST_AT:
			actions_done = -1 # Say it once.
			say("no player of mine (my id %d) so no actions" % Net.my_id())
		return
	if actions_done == 0 and match_clock >= CHEST_AT:
		actions_done = 1
		var chest: Node = tree.current_scene.get_node("Chests").get_child(0)
		say("action open %s" % chest.name)
		Net.tell_host(chest._ask_open, Net.my_id())
	elif actions_done == 1 and match_clock >= WALL_AT:
		actions_done = 2
		say("action wall at %s" % WALL_SPOT)
		Net.tell_host(me._ask_wall, Transform3D(Basis(), WALL_SPOT))
	elif actions_done == 2 and match_clock >= SHOOT_AT:
		actions_done = 3
		var bots := tree.get_nodes_in_group("bot")
		if bots.is_empty():
			say("action shoot: no bots left")
		else:
			say("action shoot %s" % bots[0].get_path())
			bots[0].hurt(Tune.rifle_damage, me)


## Step 3: when the storm clock passes 10, 30, 60 s, print everything we see.
func _snapshots() -> void:
	var storm: Node = get_tree().get_first_node_in_group("storm")
	if storm == null or snaps_done >= SNAP_TIMES.size():
		return
	var t: float = SNAP_TIMES[snaps_done]
	if storm.time < t:
		return
	snaps_done += 1
	say("snap " + JSON.stringify(_snapshot(t, storm)))
	if snaps_done == SNAP_TIMES.size():
		say("done")
		# Give the last messages a moment, then stop.
		get_tree().create_timer(2.0).timeout.connect(get_tree().quit)


func _snapshot(t: float, storm: Node) -> Dictionary:
	var scene := get_tree().current_scene
	var people := []
	for p in scene.get_node("Players").get_children():
		people.append(_fighter(p))
	var bots := []
	for b in scene.get_node("Bots").get_children():
		bots.append(_fighter(b))
	var chests := []
	for c in scene.get_node("Chests").get_children():
		if c.opened:
			chests.append(c.name)
	var walls := []
	for w in scene.get_node("Walls").get_children():
		walls.append(_vec(w.global_position))
	return {
		"t": t,
		"players": people,
		"bots": bots,
		"storm": {"center": [storm.center.x, storm.center.y], "radius": storm.radius},
		"chests_open": chests,
		"walls": walls,
	}


func _fighter(f: Node) -> Dictionary:
	return {"path": str(f.get_path()), "pos": _vec(f.global_position), "hp": f.hp, "out": f.is_out,
		"owner": Net.owner_of(f), "mine": f.is_in_group("player")}


func _vec(v: Vector3) -> Array:
	return [snappedf(v.x, 0.01), snappedf(v.y, 0.01), snappedf(v.z, 0.01)]
