extends StaticBody3D
## A tray wall you built: a giant lunch tray on its edge. It soaks up tomatoes until it is too messy and falls over.
## Online: the host keeps how much it can still soak up, and removes it on every screen.

var hp := 150.0


func _ready() -> void:
	add_to_group("wall")
	hp = Tune.wall_hp
	# One build square wide and tall: the tray in the middle, a darker rim around the edge.
	$Crust.mesh.size = Vector3(Tune.build_grid, Tune.build_grid, 0.22)
	$Mesh.mesh.size = Vector3(Tune.build_grid - 0.4, Tune.build_grid - 0.4, 0.3)
	$Shape.shape.size = Vector3(Tune.build_grid, Tune.build_grid, 0.3)


## Tomatoes that hit the wall splat the tray instead of you. Asks the host.
func take_damage(amount: float, _by: Node) -> void:
	Net.tell_host(_ask_hurt, amount)


## Runs on the host.
func _ask_hurt(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		Net.remove_for_everyone(self)
