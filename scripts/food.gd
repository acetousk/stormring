extends Node3D
## A thrown tomato: flies in an arc, then splats on the first thing it touches.
## Every screen shows its own copy. Only the thrower's copy is "real":
## it tells the host who got splatted. The other copies are just for looks.

const SPLAT_SCENE := preload("res://scenes/splat.tscn")
const LIFE := 4.0 ## Seconds before a tomato that hit nothing goes away

## Speed and direction, in meters per second.
var velocity := Vector3.ZERO
## Who threw it (so it does not hit them).
var thrower: Node3D = null
## True on the thrower's screen: this copy makes people less clean.
var real := false
var age := 0.0
## A see-through swoosh behind the tomato, so you can follow where it flies.
var trail: MeshInstance3D

const TRAIL_LENGTH := 1.6 ## Meters of swoosh behind a flying tomato
const HIDE_NEAR_CAMERA := 3.0 ## Meters: closer to your camera than this, the tomato is hidden (so it never fills the screen)


func _ready() -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.16 # The end next to the tomato is fat...
	mesh.bottom_radius = 0.01 # ...and the tail is thin.
	mesh.height = TRAIL_LENGTH
	mesh.radial_segments = 6
	mesh.rings = 1
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.945, 0.839, 0.35) # Cream, see-through
	mesh.material = mat
	trail = MeshInstance3D.new()
	trail.mesh = mesh
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	trail.top_level = true # It points along the flight, not along the spinning tomato.
	add_child(trail)


func _process(_delta: float) -> void:
	# Lay the swoosh along the flight, behind the tomato.
	if velocity.length() > 0.1:
		var back := -velocity.normalized()
		trail.global_position = global_position + back * TRAIL_LENGTH / 2.0
		var side := back.cross(Vector3.UP)
		if side.length() < 0.01:
			side = Vector3.RIGHT
		trail.global_basis = Basis(side.normalized(), -back, side.cross(-back).normalized())
	# Too close to your camera (like when you throw from under a table)? Hide it.
	var cam := get_viewport().get_camera_3d()
	visible = cam == null or cam.global_position.distance_to(global_position) > HIDE_NEAR_CAMERA


func _physics_process(delta: float) -> void:
	age += delta
	if age > LIFE:
		queue_free()
		return
	# Fall a bit faster each step: this makes the arc.
	velocity.y -= Tune.food_gravity * delta
	var from := global_position
	var to := from + velocity * delta
	# Did it touch something between this step and the next?
	var skip: Array[RID] = []
	if is_instance_valid(thrower):
		skip.append(thrower.get_rid())
	var query := PhysicsRayQueryParameters3D.create(from, to, 1, skip)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		global_position = to
		# Spin a little while it flies.
		rotate_x(8.0 * delta)
		return
	_splat(hit)


func _splat(hit: Dictionary) -> void:
	# It hit YOU (on your screen): the HUD puts the mess on the side it came from.
	# First, so the HUD knows it was a tomato when your clean goes down.
	if hit.collider is Fighter and hit.collider.is_in_group("player"):
		var hud := get_tree().current_scene.get_node_or_null("HUD")
		if hud:
			hud.hit_from(global_position - velocity)
	if real:
		# The thrower can be gone by now (splatted while the tomato flew).
		var by: Fighter = thrower if is_instance_valid(thrower) and thrower is Fighter else null
		if hit.collider is Fighter:
			hit.collider.hurt(Tune.tomato_splat, by)
			# Your own tomato hit someone: show it on your HUD and play a "ding".
			if by and by.is_in_group("player"):
				var hud := get_tree().current_scene.get_node_or_null("HUD")
				if hud:
					hud.hit_marker()
				Sfx.play_here("hit")
		elif hit.collider.has_method("take_damage"):
			hit.collider.take_damage(Tune.tomato_splat, by) # Tray walls soak it up
	# Every screen shows the splat and plays the sound for its own copy.
	var splat: Node3D = SPLAT_SCENE.instantiate()
	get_parent().add_child(splat)
	splat.place(hit.position, hit.normal, hit.collider is Fighter)
	Sfx.play("splat", hit.position)
	queue_free()
