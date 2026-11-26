extends SceneTree
# Robot playtest (see the `feature` skill, 4b). Plays one Solo match like a simple kid:
# jump off the table, get tomatoes from the nearest lunch box, chase and throw at
# the nearest buddy, wipe with a napkin when messy, stay out of the jello.
# Run with a window (screenshots need a screen):
#   godot --fixed-fps 30 -s res://tools/autoplay.gd -- 120
#   godot --fixed-fps 30 -s res://tools/autoplay.gd -- 30 outside   (test the jello warning)
# Prints PLAY lines and saves screenshots to .godot/autoplay/ (or $AUTOPLAY_OUT).
var out := ""
var max_s := 150.0
var frame := 0
var t := 0.0
var p: Node3D
var path: PackedVector3Array = []
var path_i := 0
var path_timer := 0.0
var goal_name := ""
var last_pos := Vector3.ZERO
var stuck := 0.0
var stuck_total := 0.0
var throws := 0
var hp_log := []
var shot_n := 0
var next_shot := 2.0
var next_log := 0.0
var held := {}
var ended := false
var seen_modes := {}
var cur_mode := ""
var mode_since := 0.0
var end_frame := 0
var test := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	max_s = float(a[0]) if a.size() > 0 else 120.0
	test = a[1] if a.size() > 1 else ""
	out = OS.get_environment("AUTOPLAY_OUT")
	if out == "":
		out = ProjectSettings.globalize_path("res://.godot/autoplay") # In the project, and git-ignored
	DirAccess.make_dir_recursive_absolute(out)
	print("PLAY screenshots go to ", out)
	change_scene_to_file("res://scenes/main.tscn")


func _hold(action: String, on: bool) -> void:
	if held.get(action, false) == on:
		return
	held[action] = on
	if on:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _shot(tag: String) -> void:
	var img := root.get_texture().get_image()
	if img:
		shot_n += 1
		img.save_png("%s/shot_%02d_%03ds_%s.png" % [out, shot_n, int(t), tag])


func _nearest(nodes: Array, from: Vector3) -> Node3D:
	var best: Node3D = null
	var bd := INF
	for n in nodes:
		var d := from.distance_to(n.global_position)
		if d < bd:
			bd = d
			best = n
	return best


func _go(to: Vector3, name: String) -> void:
	if name != goal_name or path_timer <= 0.0 or path_i >= path.size():
		goal_name = name
		path_timer = 1.0
		var map: RID = p.get_world_3d().navigation_map
		path = NavigationServer3D.map_get_path(map, p.global_position, to, true)
		path_i = 0
	while path_i < path.size() and Vector2(path[path_i].x - p.global_position.x, path[path_i].z - p.global_position.z).length() < 1.0:
		path_i += 1
	var aim := to if path_i >= path.size() else path[path_i]
	# On a table top (tables run east-west): first jump off the long side.
	if p.global_position.y > 3.0 and p.is_on_floor():
		aim = p.global_position + Vector3(0, 0, 4.0 * signf(to.z - p.global_position.z + 0.01))
	var d := aim - p.global_position
	if Vector2(d.x, d.z).length() > 0.3:
		p.get_node("CamYaw").rotation.y = atan2(-d.x, -d.z)
		_hold("move_forward", true)
	else:
		_hold("move_forward", false)


func _process(delta: float) -> bool:
	frame += 1
	t += delta
	var scene := current_scene
	if scene == null or not scene.has_node("Players"):
		return false
	if p == null:
		p = get_first_node_in_group("player")
		if p == null:
			return false
		last_pos = p.global_position
	if ended:
		return frame > end_frame + 45
	if scene.game_over:
		ended = true
		end_frame = frame
		for k in held.keys():
			_hold(k, false)
		_shot("end")
		_report("end")
		return false
	if t > max_s:
		_shot("timeout")
		_report("timeout")
		return true
	path_timer -= delta
	if test == "outside" and t > 3.0:
		var st := get_first_node_in_group("storm")
		if t < 3.1:
			p.global_position = Vector3(st.center.x + st.radius + 12.0, 0.5, st.center.y)
			p.velocity = Vector3.ZERO
		if t > 4.5:
			_shot("outside")
			_report("test")
			return true
		return false
	var storm := get_first_node_in_group("storm")
	var bots := get_nodes_in_group("bot")
	var chests := []
	for c in scene.get_node("Chests").get_children():
		if not c.opened:
			chests.append(c)
	var mode := ""
	_hold("fire", false)
	_hold("action", false)
	_hold("heal", false)
	_hold("aim", false)
	_hold("move_left", false)
	_hold("move_right", false)
	# Napkin when messy.
	if p.hp < 60 and p.napkins > 0 and p.wipe_left <= 0.0:
		_hold("heal", true)
	var target: Node3D = _nearest(bots, p.global_position)
	var tdist: float = INF if target == null else p.global_position.distance_to(target.global_position)
	if storm and not storm.is_safe(p.global_position):
		mode = "run from jello"
		_go(Vector3(storm.center.x, 0.2, storm.center.y), "storm")
	elif not p.has_tomatoes:
		var c: Node3D = _nearest(chests, p.global_position)
		if c == null:
			mode = "no lunch box left"
		else:
			mode = "get lunch box"
			if p.global_position.distance_to(c.global_position) < 2.2:
				_hold("move_forward", false)
				_hold("action", true)
			else:
				_go(c.global_position, "chest%s" % c.name)
	elif target and tdist < 35.0:
		mode = "fight"
		# Aim like a kid with a mouse: put the crosshair (camera center) on the buddy.
		var cam: Camera3D = p.get_node("CamYaw/CamPitch/SpringArm/Camera")
		var to: Vector3 = target.global_position + Vector3(0, 1.0, 0) - cam.global_position
		var flat := Vector2(to.x, to.z).length()
		var yaw := atan2(-to.x, -to.z)
		var cy: Node3D = p.get_node("CamYaw")
		cy.rotation.y = lerp_angle(cy.rotation.y, yaw, 0.5)
		p.get_node("CamYaw/CamPitch").rotation.x = clampf(atan2(to.y, flat), -1.2, 0.8)
		_hold("aim", true)
		_hold("move_forward", tdist > 18.0)
		# Step side to side like a kid dodging (switch every 1.2 s).
		var left_now := int(t / 1.2) % 2 == 0
		_hold("move_left", left_now)
		_hold("move_right", not left_now)
		# Press 2 for tomatoes for one frame (the release comes on the next frame).
		_hold("slot_2", p.slot != 2)
		if p.tomatoes > 0 and p.throw_cooldown <= 0.0:
			_hold("fire", true)
			throws += 1
	elif target:
		mode = "chase"
		_go(target.global_position, "bot")
	else:
		mode = "idle"
		_hold("move_forward", false)
	# Stuck: barely moved while trying to move.
	if held.get("move_forward", false):
		if p.global_position.distance_to(last_pos) < 1.5 * delta:
			stuck += delta
		else:
			stuck = 0.0
		if stuck > 1.0:
			stuck_total += delta
			_hold("jump", true)
			path_timer = 0.0
		else:
			_hold("jump", false)
	last_pos = p.global_position
	if t >= next_log:
		next_log += 2.0
		print("PLAY t=%d mode=%s clean=%d tomatoes=%d napkins=%d trays=%d gliding=%s y=%.1f bots=%d dist=%.0f jello=%s" % [
			t, mode, p.hp, p.tomatoes, p.napkins, p.trays, p.gliding, p.global_position.y, bots.size(), tdist,
			"outside" if storm and not storm.is_safe(p.global_position) else "safe"])
	if mode != cur_mode:
		cur_mode = mode
		mode_since = t
	if not seen_modes.has(mode) and mode in ["run from jello", "fight"] and t > 1.0 and t - mode_since > 1.0:
		seen_modes[mode] = true
		_shot("first-" + mode.replace(" ", "-"))
	if t >= next_shot:
		next_shot += 6.0
		_shot(mode.replace(" ", "-"))
	return false


func _report(how: String) -> void:
	print("PLAY_END how=%s t=%d clean=%d throws=%d splats=%d stuck_seconds=%.1f bots_left=%d" % [
		how, t, p.hp, throws, p.eliminations, stuck_total, get_nodes_in_group("bot").size()])
