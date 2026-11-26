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
	if real:
		var by: Fighter = thrower if thrower is Fighter else null
		if hit.collider is Fighter:
			hit.collider.hurt(Tune.tomato_splat, by)
		elif hit.collider.has_method("take_damage"):
			hit.collider.take_damage(Tune.tomato_splat, by) # Tray walls soak it up
	# Every screen shows the splat and plays the sound for its own copy.
	var splat: Node3D = SPLAT_SCENE.instantiate()
	get_parent().add_child(splat)
	splat.place(hit.position, hit.normal, hit.collider is Fighter)
	Sfx.play("splat", hit.position)
	queue_free()
