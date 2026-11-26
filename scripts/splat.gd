extends Node3D
## A tomato splat: a flat red puddle on the ground or a wall, and a few drops
## that fly out. It fades away after a few seconds.

const STAY := 5.0 ## Seconds the puddle stays before it fades
const FADE := 1.0 ## Seconds the fade takes
const MOST := 40 ## Most puddles at once (the oldest go first, so phones stay fast)

var age := 0.0
var mat: StandardMaterial3D

@onready var puddle: MeshInstance3D = $Puddle
@onready var drops: CPUParticles3D = $Drops


## Put the splat at a spot, flat against the surface it hit.
## On a person there is no puddle (it would float when they move), only drops.
func place(spot: Vector3, normal: Vector3, on_person: bool) -> void:
	add_to_group("splat")
	global_position = spot + normal * 0.03
	# Turn so the puddle lies flat on the surface.
	if absf(normal.dot(Vector3.UP)) < 0.99:
		look_at(global_position + normal, Vector3.UP)
		rotate_object_local(Vector3.RIGHT, -PI / 2.0)
	puddle.rotate_y(randf() * TAU)
	puddle.scale = Vector3.ONE * randf_range(0.8, 1.3)
	puddle.visible = not on_person
	mat = puddle.mesh.material.duplicate()
	puddle.material_override = mat
	drops.emitting = true
	# Too many puddles? Remove the oldest.
	var all := get_tree().get_nodes_in_group("splat")
	if all.size() > MOST:
		all[0].queue_free()


func _process(delta: float) -> void:
	age += delta
	if age > STAY:
		mat.albedo_color.a = 1.0 - (age - STAY) / FADE
	if age > STAY + FADE:
		queue_free()
