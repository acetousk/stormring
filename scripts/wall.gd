extends StaticBody3D
## A wall you built: blocks bullets until its HP runs out.
## Online: the host keeps the wall's HP and breaks it on every screen.

var hp := 150.0


func _ready() -> void:
	add_to_group("wall")
	hp = Tune.wall_hp
	# One build square wide and tall.
	$Mesh.mesh.size = Vector3(Tune.build_grid, Tune.build_grid, 0.2)
	$Shape.shape.size = Vector3(Tune.build_grid, Tune.build_grid, 0.2)


## Bullets that hit the wall hurt the wall instead of you. Asks the host.
func take_damage(amount: float, _by: Node) -> void:
	Net.tell_host(_ask_hurt, amount)


## Runs on the host.
func _ask_hurt(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		Net.remove_for_everyone(self)
