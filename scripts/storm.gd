extends Node3D
## The storm: a circle on the island. Inside is safe, outside hurts.

## Middle of the safe circle (x and z on the ground).
var center := Vector2.ZERO
## How big the safe circle is, in meters.
var radius := 80.0
## Seconds since the match started.
var time := 0.0
## True while the circle is getting smaller.
var shrinking := false
## Counts up to 1 second between storm hits.
var tick := 0.0

@onready var wall: MeshInstance3D = $Wall


func _ready() -> void:
	add_to_group("storm")
	# Local mode has no key for quick messages: send the storm the sure way there.
	$StormSync.reliable = Net.is_local()
	# Pick a middle near the center of the island, different each match.
	center = Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
	radius = Tune.storm_start_radius
	_update_wall()


func _process(delta: float) -> void:
	# Online: only the host runs the storm clock. Other screens get its
	# center and time from the host (StormSync) and draw the same circle.
	if Net.is_host():
		time += delta
	# First wait, then shrink smoothly from the start size down to 0.
	shrinking = time > Tune.storm_wait
	radius = Tune.storm_start_radius * (1.0 - shrink_part())
	_update_wall()
	# Hum while YOUR player is outside the circle (each screen checks its own).
	var me: Node3D = get_tree().get_first_node_in_group("player")
	Sfx.loop("storm", me != null and not me.is_out and not is_safe(me.global_position))
	if not Net.is_host():
		return

	# Once a second: hurt everyone outside. Smaller circle = more damage.
	tick += delta
	if tick >= 1.0:
		tick -= 1.0
		var damage := lerpf(Tune.storm_dps_start, Tune.storm_dps_end, shrink_part())
		for fighter in get_tree().get_nodes_in_group("fighter"):
			if not is_safe(fighter.global_position):
				fighter.take_damage(damage, null)


func _exit_tree() -> void:
	Sfx.loop("storm", false) # Match over or new match: stop the hum.


## Seconds left: until it starts shrinking, or until it is fully closed.
func time_left() -> float:
	if not shrinking:
		return Tune.storm_wait - time
	return maxf(Tune.storm_wait + Tune.storm_shrink_time - time, 0.0)


## How far along the shrink is: 0 = not started, 1 = closed.
func shrink_part() -> float:
	return clampf((time - Tune.storm_wait) / Tune.storm_shrink_time, 0.0, 1.0)


## Move and size the purple wall to match the circle.
func _update_wall() -> void:
	wall.position = Vector3(center.x, 0.0, center.y)
	wall.scale = Vector3(maxf(radius, 0.01), 1.0, maxf(radius, 0.01))


## True if a spot is inside the safe circle.
func is_safe(spot: Vector3) -> bool:
	return Vector2(spot.x, spot.z).distance_to(center) <= radius
