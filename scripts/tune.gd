extends Node
## Tune: every feel number in the game. Change these to change how it feels.

@export_group("Moving")
@export var run_speed: float = 7.0 ## How fast you run, in meters per second
@export var jump_height: float = 1.2 ## How high a jump goes, in meters
@export var gravity: float = 20.0 ## How hard you fall (higher = snappier jumps)

@export_group("Looking")
@export var look_speed: float = 0.003 ## Mouse look speed (higher = turn faster)
@export var stick_look_speed: float = 3.0 ## Gamepad right-stick look speed
@export var touch_look_speed: float = 0.006 ## Touch look speed: drag on the right side (higher = turn faster)
@export var normal_fov: float = 75.0 ## How wide the camera sees normally, in degrees
@export var aim_fov: float = 50.0 ## How wide the camera sees when aiming (lower = more zoom)
@export var aim_look_slow: float = 0.5 ## Look speed while aiming (0.5 = half speed)

@export_group("Lunch boxes")
@export var chest_open_time: float = 0.5 ## Seconds you hold the action button to open a lunch box
@export var max_napkins: int = 2 ## Most napkins you can carry
@export var napkin_clean: float = 50.0 ## How much cleaner one napkin makes you
@export var napkin_time: float = 3.0 ## Seconds a napkin takes to wipe you clean
@export var max_hp: float = 100.0 ## How clean you are at the start. At 0 you are splatted.

@export_group("Tomatoes")
@export var tomato_bag: int = 6 ## Tomatoes in your hands before you grab more from the lunch box
@export var tomato_splat: float = 10.0 ## How much less clean one tomato makes someone
@export var throw_every: float = 0.35 ## Seconds from one throw to the next
@export var throw_speed: float = 28.0 ## How fast a tomato flies, in meters per second
@export var food_gravity: float = 9.8 ## How fast a tomato falls (higher = bigger arc)
@export var throw_range: float = 50.0 ## The farthest spot you can aim at, in meters
@export var refill_time: float = 1.2 ## Seconds to grab more tomatoes

@export_group("Trays")
@export var trays_per_hit: int = 1 ## Trays you grab from a tray cart with one spoon hit
@export var max_trays: int = 30 ## Most trays you can carry
@export var spoon_reach: float = 2.5 ## How far the spoon reaches, in meters
@export var spoon_swing_every: float = 0.3 ## Seconds between spoon swings
@export var wall_cost: int = 1 ## Trays one tray wall costs
@export var wall_hp: float = 150.0 ## How much splat a tray wall soaks up before it falls apart
@export var build_grid: float = 4.0 ## Size of one build square, in meters (walls are this wide and tall)

@export_group("Bots")
@export var bot_speed: float = 5.0 ## How fast bots walk, in meters per second
@export var bot_sight: float = 45.0 ## How far bots can see someone, in meters
@export var bot_throw_every: float = 0.8 ## Seconds between bot throws (higher = easier bots)
@export var bot_miss_far: float = 3.0 ## How far off a bot aims at the edge of sight, in meters
@export var bot_miss_near: float = 0.6 ## How far off a bot aims up close, in meters
@export var bot_napkins: int = 1 ## Napkins each bot starts with
@export var bot_wipe_below: float = 40.0 ## A bot uses a napkin when it is less clean than this

@export_group("Jello spill")
@export var storm_start_radius: float = 80.0 ## Size of the safe circle at the start, in meters
@export var storm_wait: float = 35.0 ## Seconds before the jello spill starts to spread
@export var storm_shrink_time: float = 90.0 ## Seconds the jello takes to close in all the way to 0
@export var storm_dps_start: float = 2.0 ## How much clean you lose each second outside the circle at the start
@export var storm_dps_end: float = 10.0 ## How much clean you lose each second outside the circle when it is fully closed

@export_group("Sound")
@export_range(0.0, 1.0, 0.05) var sfx_volume: float = 0.7 ## How loud all sounds are (0 = silent, 1 = full)
@export_range(0.0, 1.0, 0.05) var storm_hum_volume: float = 0.6 ## How loud the jello spill wobble are, on top of sfx_volume

@export_group("Touch")
@export var force_touch: bool = false ## Show the phone controls on your PC too (the mouse acts like a finger)

@export_group("Online")
@export var net_send_rate: int = 20 ## How many times a second player and bot spots are sent to the others (higher = smoother, more data)

@export_group("Napkin parachute")
@export var napkin_open_speed: float = 7.5 ## Falling faster than this (meters per second) opens your napkin parachute
@export var glide_fall: float = 3.0 ## How fast you sink under your napkin, in meters per second
@export var glide_steer: float = 8.0 ## How fast you move sideways while gliding
