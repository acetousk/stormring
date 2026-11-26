extends Node
## Net: all the online code. Talks to GD-Sync.
## In the Godot editor we use local mode (no key, same computer or Wi-Fi).
## In exported builds we use online mode (needs the key, works in a browser).

signal status_changed(text: String)
signal room_changed
signal player_left(client_id: int)

const MAX_PLAYERS := 4

var status := "Not connected"
var connected := false
var room_code := "" ## The 4-digit room you are in ("" = no room)
var online := false ## True during an online match (false in solo)


func _ready() -> void:
	GDSync.connected.connect(_on_connected)
	GDSync.connection_failed.connect(_on_connection_failed)
	GDSync.disconnected.connect(_on_disconnected)
	GDSync.lobby_created.connect(_on_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_lobby_creation_failed)
	GDSync.lobby_joined.connect(_on_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_lobby_join_failed)
	GDSync.client_joined.connect(_on_players_changed)
	GDSync.client_left.connect(_on_players_changed)
	GDSync.client_left.connect(player_left.emit)
	GDSync.change_scene_called.connect(_on_match_starting)
	start()
	# Only for tools/net_test.py: a robot that hosts or joins by itself.
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--net-test="):
			add_child(load("res://tools/net_test.gd").new())


## Connect to GD-Sync. Local mode in the editor, online mode in builds.
func start() -> void:
	if connected:
		return
	_set_status("Connecting…")
	if OS.has_feature("editor"):
		GDSync.start_local_multiplayer()
	else:
		GDSync.start_multiplayer()


func is_local() -> bool:
	return OS.has_feature("editor")


func player_count() -> int:
	return GDSync.lobby_get_player_count() if room_code != "" else 0


## Make a new room with a random 4-digit code, then join it.
## (The net test picks the code itself.)
func host_room(code := "") -> void:
	if not connected:
		_set_status("Not connected yet, wait a second")
		return
	if code == "":
		code = str(randi_range(1000, 9999))
	_set_status("Making room %s…" % code)
	# Private (not listed), max 4 players. You join with the code.
	GDSync.lobby_create(code, "", false, MAX_PLAYERS)


## Join a friend's room by its 4-digit code.
func join_room(code: String) -> void:
	if not connected:
		_set_status("Not connected yet, wait a second")
		return
	if code.length() != 4:
		_set_status("A room code has 4 digits")
		return
	_set_status("Joining room %s…" % code)
	GDSync.lobby_join(code)


## True if you are in a room and you made it (the host runs the match).
func in_room_as_host() -> bool:
	return room_code != "" and GDSync.is_host()


## Solo counts as host: your game runs everything.
func is_host() -> bool:
	return not online or GDSync.is_host()


## Host only: close the room and load the lunchroom on every screen.
func start_match() -> void:
	if not in_room_as_host():
		return
	GDSync.lobby_close() # Nobody can join in the middle of a match.
	GDSync.change_scene("res://scenes/main.tscn")


func _on_match_starting(_path: String) -> void:
	online = true
	GDSync.expose_func(_relay) # Others may send the host their "_ask_" requests.


## Everyone in the room, by their client ID.
func everyone() -> Array:
	return GDSync.lobby_get_all_clients()


## Host only: make a node on every screen (same name and place everywhere).
func spawn_for_everyone(scene: PackedScene, parent: Node) -> Node:
	return GDSync.multiplayer_instantiate(scene, parent)


## Host only: remove a node from every screen. In solo, just here.
func remove_for_everyone(node: Node) -> void:
	if online:
		GDSync.multiplayer_queue_free(node)
	else:
		node.queue_free()


## Host only: say which person controls this node.
func give_to(node: Node, client_id: int) -> void:
	GDSync.set_gdsync_owner(node, client_id)


## The client ID of the person who controls this node (-1 = nobody).
func owner_of(node: Node) -> int:
	return GDSync.get_gdsync_owner(node)


## After an online match: leave the room (you can host or join a new one).
func leave_room() -> void:
	if room_code != "":
		GDSync.lobby_leave()
	room_code = ""
	online = false
	_set_status("Connected (%s)" % ("local" if is_local() else "online"))


## True if this node is yours to control. In solo, everything is yours.
func is_mine(node: Node) -> bool:
	return not online or GDSync.is_gdsync_owner(node)


## Your client ID (0 in solo).
func my_id() -> int:
	return GDSync.get_client_id() if online else 0


## Let other screens call this function on this node.
## host_only = only the host may call it (for things only the host decides).
func allow(callable: Callable, host_only := false) -> void:
	if online:
		var who := ENUMS.EXPOSE_PERMISSION.HOST if host_only else ENUMS.EXPOSE_PERMISSION.ANYONE
		GDSync.expose_func(callable, who)


## Ask the host to run this. In solo (or if you are the host) it runs right here.
## Only for functions whose name starts with "_ask_".
## We send it to everyone and only the host does it: GD-Sync's "send to one
## player" loses the message when the host's ID number is too big (local mode).
func tell_host(callable: Callable, ...args: Array) -> void:
	if not online or GDSync.is_host():
		callable.callv(args)
	else:
		var node: Node = callable.get_object()
		GDSync.call_func(_relay, str(node.get_path()), callable.get_method(), args)


## Runs on every other screen; only the host does the request.
func _relay(path: String, method: String, args: Array) -> void:
	if not GDSync.is_host() or not method.begins_with("_ask_"):
		return
	print("Net: request %s on %s" % [method, path])
	var node := get_node_or_null(path)
	if node and node.has_method(method):
		node.callv(method, args)


## Host: run this on every screen, your own too.
func tell_everyone(callable: Callable, ...args: Array) -> void:
	if not online:
		callable.callv(args)
	else:
		GDSync.call_func_all.callv([callable] + args)


func _on_connected() -> void:
	connected = true
	_set_status("Connected (%s)" % ("local" if is_local() else "online"))


func _on_connection_failed(error: int) -> void:
	connected = false
	_set_status("Could not connect (error %d)" % error)


func _on_disconnected() -> void:
	connected = false
	room_code = ""
	_set_status("Disconnected")


func _on_lobby_created(code: String) -> void:
	# Making a room does not put you in it. Join within 5 seconds.
	GDSync.lobby_join(code)


func _on_lobby_creation_failed(code: String, error: int) -> void:
	if error == ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
		host_room() # Code taken, try another one.
	else:
		_set_status("Could not make room %s (error %d)" % [code, error])


func _on_lobby_joined(code: String) -> void:
	room_code = code
	_on_players_changed(0)


func _on_lobby_join_failed(code: String, error: int) -> void:
	match error:
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			_set_status("No room %s, check the code" % code)
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			_set_status("Room %s is full" % code)
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_CLOSED:
			_set_status("Room %s already started" % code)
		_:
			_set_status("Could not join room %s (error %d)" % [code, error])


func _on_players_changed(_client_id: int) -> void:
	if room_code == "":
		return
	var role := "host" if GDSync.is_host() else "guest"
	_set_status("Room %s  players %d/%d  (you are %s)" % [room_code, player_count(), MAX_PLAYERS, role])
	room_changed.emit()


func _set_status(text: String) -> void:
	status = text
	print("Net: ", text)
	status_changed.emit(text)
