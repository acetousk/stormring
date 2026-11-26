extends Node3D
## The game: builds the walking map, spawns players and bots, makes the tomatoes,
## and decides who wins.

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const FOOD_SCENE := preload("res://scenes/food.tscn")
const BOT_SCENE := preload("res://scenes/bot.tscn")
## Where the bots start: on the floor, between the tables.
const BOT_SPAWNS := [Vector3(-21, 1, -15), Vector3(21, 1, 15), Vector3(0, 1, -30)]
## How high above a lunch table's spot a player starts (on the table top).
const TABLE_TOP := Vector3(0, 5.4, 0)

var game_over := false
## Seconds before you can restart (so a held button does not skip the message).
var restart_wait := 0.0
var match_time := 0.0

@onready var nav_region: NavigationRegion3D = $NavRegion
@onready var players: Node3D = $Players
@onready var bots: Node3D = $Bots
@onready var hud: CanvasLayer = $HUD
@onready var thrown: Node3D = $Thrown


func _ready() -> void:
	# Work out where you can walk in the lunchroom (no threads, for the web).
	nav_region.bake_navigation_mesh(false)
	# Every player or bot that shows up (made here or by the host) can be eliminated.
	players.child_entered_tree.connect(_on_fighter_added)
	bots.child_entered_tree.connect(_on_fighter_added)
	Net.player_left.connect(_on_player_left)
	Net.allow(Sfx.play) # Online: other screens may play sounds (throws, builds) on mine.
	Net.allow(_food_seen) # Online: other screens may show their tomatoes on mine.
	# The school bell rings: the food fight starts (every screen rings its own).
	Sfx.play_everywhere("bell")

	if not Net.online:
		# Solo: one player (you) and the bots.
		var me: Fighter = PLAYER_SCENE.instantiate()
		me.position = _table_spot(0)
		players.add_child(me)
		me.become_local()
		_spawn_bots()
	elif Net.is_host():
		# Online: the host makes one player per person, then the bots.
		# Wait a moment so every screen has loaded the lunchroom.
		await get_tree().create_timer(0.5).timeout
		var ids := Net.everyone()
		var made: Array[Fighter] = []
		for i in ids.size():
			var p: Fighter = Net.spawn_for_everyone(PLAYER_SCENE, players)
			p.position = _table_spot(i)
			made.append(p)
		_spawn_bots()
		# Wait 1 s so the players exist on every screen, THEN say whose is whose.
		# (Said too early, the message is lost and that person never gets control.)
		await get_tree().create_timer(1.0).timeout
		for i in made.size():
			Net.give_to(made[i], ids[i])


## The top of lunch table number `i`: everyone starts on a different table.
func _table_spot(i: int) -> Vector3:
	var tables := get_tree().get_nodes_in_group("table")
	return tables[i % tables.size()].global_position + TABLE_TOP


## Solo: make the bots here. Online: the host makes them on every screen.
func _spawn_bots() -> void:
	for i in BOT_SPAWNS.size():
		var bot: Fighter
		if Net.online:
			bot = Net.spawn_for_everyone(BOT_SCENE, bots)
		else:
			bot = BOT_SCENE.instantiate()
			bot.name = "Bot%d" % (i + 1)
			bots.add_child(bot)
		bot.position = BOT_SPAWNS[i]


## Throw a tomato from a spot so it lands on `target`, at `speed` m/s.
## The arc: aim a bit higher, by exactly how much the tomato falls on the way.
func throw_food(from: Vector3, speed: float, target: Vector3, by: Fighter) -> void:
	var time := maxf(from.distance_to(target) / speed, 0.05) # Seconds in the air
	var velocity := (target - from) / time + Vector3.UP * 0.5 * Tune.food_gravity * time
	Sfx.play_for_everyone("throw", from)
	# Every screen makes its own copy of the tomato (also this one).
	Net.tell_everyone(_food_seen, from, velocity, str(by.get_path()))


## Runs on every screen: show a flying tomato.
func _food_seen(from: Vector3, velocity: Vector3, by_path: String) -> void:
	var by := get_node_or_null(by_path) as Fighter
	var food: Node3D = FOOD_SCENE.instantiate()
	food.velocity = velocity
	food.thrower = by
	# Only the copy on the thrower's own screen splats people for real.
	# Your player: your screen. Bots: the host runs them.
	if by and by.is_in_group("bot"):
		food.real = Net.is_host()
	else:
		food.real = by != null and by.get("is_local") == true
	thrown.add_child(food)
	food.global_position = from


func _on_fighter_added(node: Node) -> void:
	if node is Fighter:
		node.eliminated.connect(_on_eliminated)


## Host: someone left the room, so their player is splatted (or the match never ends).
func _on_player_left(client_id: int) -> void:
	if not Net.is_host():
		return
	for p in players.get_children():
		if p is Fighter and Net.owner_of(p) == client_id:
			p.take_damage(p.hp, null)


func _fighters_left() -> int:
	return get_tree().get_nodes_in_group("fighter").size()


## Your own player (null until the host gives it to you).
func _me() -> Fighter:
	return get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if not game_over:
		match_time += delta
	else:
		restart_wait -= delta


## Someone is splatted: check if the match is over.
func _on_eliminated(who: Fighter, _by: Fighter) -> void:
	var me := _me()
	if game_over or me == null:
		return
	var left := get_tree().get_nodes_in_group("fighter").size()
	if who == me:
		_end("Splatted!", "Place #%d" % (left + 1))
	elif left == 1 and not me.is_out:
		_end("Last one clean!", "Place #1")


func _end(title: String, place: String) -> void:
	game_over = true
	restart_wait = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var stats := "%s   Splats %d   Time %d:%02d" % [place, _me().eliminations, int(match_time) / 60, int(match_time) % 60]
	var hint := "Click, tap or press Space to go back to the start screen" if Net.online \
			else "Click, tap or press Space to play again.  Esc: start screen"
	hud.show_end(title, stats, hint)
	print("Match over: ", title, "  ", stats)


func _unhandled_input(event: InputEvent) -> void:
	# After the match: click, tap, or press jump.
	# Solo: play again. Online: leave the room and go back to the start screen.
	if game_over and restart_wait <= 0.0:
		if not Net.online and event.is_action_pressed("ui_cancel"):
			get_tree().change_scene_to_file("res://scenes/lobby.tscn") # Solo → start screen
		elif event.is_action_pressed("jump") or event.is_action_pressed("fire") or event is InputEventScreenTouch:
			if Net.online:
				# The host runs the match, so the host stays until there is a winner.
				if Net.is_host() and _fighters_left() > 1:
					hud.show_end(hud.end_title(), hud.end_stats(), "You are the host: wait for a winner")
					return
				Net.leave_room()
				get_tree().change_scene_to_file("res://scenes/lobby.tscn")
			else:
				get_tree().reload_current_scene()
