extends Fighter
## A bot (a lunch buddy) with a small brain.
## STORM = outside the circle, run to the middle (this comes first).
## ROAM = walk to random spots in the circle. FIGHT = sees someone, steps side to side and throws tomatoes.
## A bot fights back at whoever hit it, and wipes itself with a napkin when it gets messy.

enum Mode { ROAM, FIGHT, STORM }

const EYE := Vector3(0, 1.5, 0)

var mode := Mode.ROAM
var target: Node3D = null
var throw_cooldown := 0.0
var look_timer := 0.0
var strafe_dir := 1.0
var strafe_timer := 0.0
## Bots carry napkins too, and wipe themselves when they get messy.
var napkins := Tune.bot_napkins
var wipe_left := 0.0

@onready var agent: NavigationAgent3D = $Agent


func _ready() -> void:
	add_to_group("bot")
	add_to_group("fighter")
	_net_ready()
	_make_name_tag()
	# Wait one frame so the lunchroom map is ready, then pick a place to walk to.
	await get_tree().physics_frame
	_pick_roam_point()


## A name over my head, the same name the splat feed uses.
func _make_name_tag() -> void:
	var tag := Label3D.new()
	tag.text = nice_name()
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.font_size = 48
	tag.pixel_size = 0.006
	tag.modulate = Color(1, 0.945, 0.839)
	tag.outline_modulate = Color(0.149, 0.275, 0.325)
	tag.outline_size = 10
	tag.position = Vector3(0, 2.6, 0)
	tag.visibility_range_end = 30.0 # Far away, the name goes away (less clutter).
	add_child(tag)


## Choose a random spot inside the safe circle and ask the map for a path there.
func _pick_roam_point() -> void:
	var middle := Vector2.ZERO
	var size := 70.0
	var storm := get_tree().get_first_node_in_group("storm")
	if storm:
		middle = storm.center
		size = storm.radius * 0.8
	var spot := middle + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * size
	agent.target_position = Vector3(clampf(spot.x, -70, 70), 0.2, clampf(spot.y, -70, 70))


## True if nothing solid is between my eyes and theirs.
func _can_see(other: Node3D) -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position + EYE, other.global_position + EYE, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == other


## Find the closest player or bot I can see within sight range.
## Someone who just splatted me comes first, if I can see them.
func _look_for_target() -> void:
	target = null
	if is_instance_valid(last_hit_by) and not last_hit_by.is_out and _can_see(last_hit_by) \
			and global_position.distance_to(last_hit_by.global_position) < Tune.bot_sight * 1.3:
		target = last_hit_by
		mode = Mode.FIGHT
		_check_storm()
		return
	var best := Tune.bot_sight
	for other in get_tree().get_nodes_in_group("fighter"):
		if other == self:
			continue
		var dist := global_position.distance_to(other.global_position)
		if dist < best and _can_see(other):
			best = dist
			target = other
	mode = Mode.FIGHT if target else Mode.ROAM
	_check_storm()


## The jello comes first: if I am outside, run to the middle.
func _check_storm() -> void:
	var storm := get_tree().get_first_node_in_group("storm")
	if storm and not storm.is_safe(global_position):
		mode = Mode.STORM
		agent.target_position = Vector3(storm.center.x, 0.2, storm.center.y)


func _physics_process(delta: float) -> void:
	# Online: only the host runs the bot brain. Other screens copy where it is.
	if not Net.is_host():
		return
	if not is_on_floor():
		velocity.y -= Tune.gravity * delta
	_wipe(delta)

	# Look around a few times a second (not every frame, to save power).
	look_timer -= delta
	if look_timer <= 0.0:
		look_timer = 0.2
		_look_for_target()

	if mode == Mode.STORM:
		_follow_path()
	elif mode == Mode.FIGHT and is_instance_valid(target):
		_fight(delta)
	else:
		if agent.is_navigation_finished():
			_pick_roam_point()
		_follow_path()
	move_and_slide()


## Messy? Use a napkin, and get cleaner bit by bit (like the player).
func _wipe(delta: float) -> void:
	if wipe_left <= 0.0 and napkins > 0 and hp < Tune.bot_wipe_below:
		napkins -= 1
		wipe_left = Tune.napkin_clean
	if wipe_left > 0.0:
		var step := minf(Tune.napkin_clean / Tune.napkin_time * delta, wipe_left)
		wipe_left -= step
		hp = minf(hp + step, Tune.max_hp)


## Walk toward the next corner of the path.
func _follow_path() -> void:
	var direction := agent.get_next_path_position() - global_position
	direction.y = 0.0
	if direction.length() > 0.1:
		direction = direction.normalized()
		velocity.x = direction.x * Tune.bot_speed
		velocity.z = direction.z * Tune.bot_speed
		look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0


func _fight(delta: float) -> void:
	# Face the target.
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > 0.1:
		look_at(global_position + to_target, Vector3.UP)
	# Strafe: step sideways, switch side every so often.
	strafe_timer -= delta
	if strafe_timer <= 0.0:
		strafe_timer = randf_range(0.6, 1.4)
		strafe_dir = -strafe_dir
	var side := global_basis.x * strafe_dir * Tune.bot_speed * 0.6
	velocity.x = side.x
	velocity.z = side.z
	# Throw a tomato every so often.
	throw_cooldown -= delta
	if throw_cooldown <= 0.0:
		throw_cooldown = Tune.bot_throw_every * randf_range(0.8, 1.2)
		_throw_tomato()


## One bot tomato. Bots aim a bit off on purpose: far = more off, close = less.
func _throw_tomato() -> void:
	if not _can_see(target):
		return
	var dist := global_position.distance_to(target.global_position)
	var closeness := 1.0 - clampf(dist / Tune.bot_sight, 0.0, 1.0)
	var miss := lerpf(Tune.bot_miss_far, Tune.bot_miss_near, closeness)
	var off := Vector3(randf_range(-1, 1), randf_range(-0.5, 0.5), randf_range(-1, 1)) * miss
	var aim: Vector3 = target.global_position + Vector3(0, 1.0, 0) + off
	var hand := global_position + Vector3(0, 1.4, 0) + global_basis.x * 0.5
	get_tree().current_scene.throw_food(hand, Tune.throw_speed, aim, self)
