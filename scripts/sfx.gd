extends Node
## Sfx: plays the game's sounds (made by tools/make_sfx.py).
##   Sfx.play("splat", global_position)  → a sound at a spot (quieter far away)
##   Sfx.play_everywhere("bell")        → a sound you hear the same everywhere
##   Sfx.play_here("hit")               → a sound only on this screen (your own hit "ding")
##   Sfx.loop("storm", true / false)    → a sound that repeats until you stop it
## Browsers and phones block sound until you click or tap,
## so nothing plays before your first click, tap, or key press.

const SOUNDS := {
	"throw": preload("res://sounds/throw.wav"),
	"splat": preload("res://sounds/splat.wav"),
	"harvest": preload("res://sounds/harvest.wav"),
	"build": preload("res://sounds/build.wav"),
	"storm": preload("res://sounds/storm.wav"),
	"bell": preload("res://sounds/bell.wav"),
	"hit": preload("res://sounds/hit.wav"),
	"ouch": preload("res://sounds/ouch.wav"),
	"pickup": preload("res://sounds/pickup.wav"),
	"out": preload("res://sounds/out.wav"),
}
const MAX_AT_ONCE := 16 ## More than this at the same moment are skipped (keeps phones fast)
const HEAR_DISTANCE := 70.0 ## Meters: farther than this you hear nothing

var unlocked := false ## True after the first click, tap, or key
var _playing := 0
var _loops := {} ## name → AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if not unlocked and event.is_pressed() and (event is InputEventMouseButton \
			or event is InputEventScreenTouch or event is InputEventKey or event is InputEventJoypadButton):
		unlocked = true


## One sound at a spot in the world.
func play(sound: String, where: Vector3) -> void:
	if not unlocked or _playing >= MAX_AT_ONCE:
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = SOUNDS[sound]
	player.max_distance = HEAR_DISTANCE
	player.unit_size = 8.0
	player.volume_db = linear_to_db(Tune.sfx_volume)
	scene.add_child(player)
	player.global_position = where
	player.finished.connect(player.queue_free)
	# Counted down when it is gone (finished, or the match ended first).
	player.tree_exiting.connect(func() -> void: _playing -= 1)
	_playing += 1
	player.play()


## A sound only on this screen, not at a spot (your "ding" when you hit someone).
## Same as play_everywhere: online, the other screens do not hear it.
func play_here(sound: String) -> void:
	play_everywhere(sound)


## A sound everywhere at once (not at a spot), like the school bell.
func play_everywhere(sound: String) -> void:
	if not unlocked:
		return
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[sound]
	player.volume_db = linear_to_db(Tune.sfx_volume)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


## A sound that every screen hears (online), like a throw. In solo, just here.
## (game.gd lets other screens call play() when the match starts.)
func play_for_everyone(sound: String, where: Vector3) -> void:
	Net.tell_everyone(play, sound, where)


## A repeating sound (not at a spot). on = start, off = stop.
func loop(sound: String, on: bool) -> void:
	if not _loops.has(sound):
		# (storm.wav is set to loop in its Import settings.)
		var player := AudioStreamPlayer.new()
		player.stream = SOUNDS[sound]
		add_child(player)
		_loops[sound] = player
	var p: AudioStreamPlayer = _loops[sound]
	if on and unlocked and not p.playing:
		p.volume_db = linear_to_db(Tune.sfx_volume * Tune.storm_hum_volume)
		p.play()
	elif not on and p.playing:
		p.stop()

