extends Fighter
## The player: reads your controls, moves the capsule, and turns the camera.
## (HP and taking damage come from health.gd.)

## True while you float down from the sky at the start.
var gliding := false
## True once you have the Burst rifle.
var has_rifle := false
## How many heal kits you carry.
var heal_kits := 0
## HP still to come from the heal kit you are using (0 = not healing).
var heal_left := 0.0
## Shots left in the rifle before you must reload.
var ammo := 0
## Seconds until you can fire the next burst.
var fire_cooldown := 0.0
## True while you reload (you cannot shoot).
var reloading := false
## What is in your hand: 1 = pickaxe, 2 = rifle.
var slot := 1
## Building material you have collected.
var material := 0
## True while build mode is on (fire places a wall instead of shooting).
var building := false

## True when the ghost wall spot is OK to build on.
var can_build := false
var ghost_mat: StandardMaterial3D

const WALL_SCENE := preload("res://scenes/wall.tscn")
const GHOST_OK := Color(0.416, 0.6, 0.306, 0.45)  # grass green
const GHOST_NO := Color(0.482, 0.173, 0.749, 0.45)  # storm purple

@onready var ghost: MeshInstance3D = $Ghost

@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/CamPitch
@onready var spring_arm: SpringArm3D = $CamYaw/CamPitch/SpringArm
@onready var camera: Camera3D = $CamYaw/CamPitch/SpringArm/Camera


func _ready() -> void:
	add_to_group("fighter")
	# Nobody controls this player until we know it is yours (see become_local).
	camera.current = false
	set_physics_process(false)
	set_process_unhandled_input(false)
	_net_ready()
	# The selfie stick must not bump into your own body.
	spring_arm.add_excluded_object(get_rid())
	# The ghost wall is one build square wide and tall.
	ghost.mesh.size = Vector3(Tune.build_grid, Tune.build_grid, 0.2)
	# My own copy of the ghost color, so I can make it green or purple.
	ghost_mat = ghost.mesh.material.duplicate()
	ghost.material_override = ghost_mat
	# Start high in the sky and glide down.
	global_position.y = Tune.drop_height
	gliding = true


## True if this player is the one you control.
var is_local := false


## This player is yours: read your controls and look through its camera.
## Other people's players stay still here; their own game moves them.
func become_local() -> void:
	is_local = true
	add_to_group("player") # The HUD shows the "player" group: only you.
	camera.make_current()
	set_physics_process(true)
	set_process_unhandled_input(true)


func _process(delta: float) -> void:
	# Online: wait until the host says this player is yours.
	if not is_local and not is_out and Net.online and Net.is_mine(self):
		become_local()
	# The host owns HP, so the host also runs healing (HpSync sends it back).
	if Net.is_host() and heal_left > 0.0:
		var step := minf(Tune.heal_amount / Tune.heal_time * delta, heal_left)
		heal_left -= step
		hp = minf(hp + step, Tune.max_hp)
		if hp >= Tune.max_hp:
			heal_left = 0.0


## Runs on the host: start healing this player.
func _ask_heal() -> void:
	if not is_out:
		heal_left = Tune.heal_amount


## When you are out: hide your body and stop moving. The camera stays.
func _on_out() -> void:
	$Body.visible = false
	$Shape.set_deferred("disabled", true)
	heal_left = 0.0
	set_physics_process(false)
	set_process_unhandled_input(false)


## A chest calls this when you open it.
func give_loot() -> void:
	if not has_rifle:
		has_rifle = true
		ammo = Tune.rifle_mag
		slot = 2  # Your first rifle goes straight into your hand.
	heal_kits = mini(heal_kits + 1, Tune.max_heal_kits)


## Fire one burst: a few bullets, a tiny gap between each.
func _fire_burst() -> void:
	fire_cooldown = Tune.rifle_fire_every
	for i in Tune.rifle_burst_shots:
		if ammo <= 0 or reloading:
			return
		ammo -= 1
		_shoot_bullet()
		await get_tree().create_timer(Tune.rifle_burst_gap).timeout


## Reload: wait, then fill the magazine.
func _reload() -> void:
	reloading = true
	await get_tree().create_timer(Tune.rifle_reload_time).timeout
	ammo = Tune.rifle_mag
	reloading = false


## One bullet: an invisible line from the middle of the screen.
func _shoot_bullet() -> void:
	var center := get_viewport().get_visible_rect().size / 2.0
	var from := camera.project_ray_origin(center)
	var to := from + camera.project_ray_normal(center) * Tune.rifle_range
	var query := PhysicsRayQueryParameters3D.create(from, to, 1, [get_rid()])
	Sfx.play_for_everyone("shot", global_position)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	# Whatever the line touches first takes the damage (if it can).
	# Players and bots: "I hit you" goes to the host, who takes the HP.
	if hit.collider is Fighter:
		hit.collider.hurt(Tune.rifle_damage, self)
		Sfx.play("hit", global_position) # Only you hear your hits.
	elif hit.collider.has_method("take_damage"):
		hit.collider.take_damage(Tune.rifle_damage, self) # Walls ask the host too
		Sfx.play("hit", global_position)


## Pickaxe reach: a short line from your chest the way the camera looks.
func _pickaxe_hit() -> Dictionary:
	var from := global_position + Vector3(0, 1.2, 0)
	var to := from + -camera.global_basis.z * Tune.pickaxe_reach
	var query := PhysicsRayQueryParameters3D.create(from, to, 1, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query)


## True if a tree, rock, or house is close enough to hit with the pickaxe.
func _facing_harvest() -> bool:
	var hit := _pickaxe_hit()
	return not hit.is_empty() and hit.collider.get_parent().is_in_group("harvest")


## Pickaxe swing.
func _swing_pickaxe() -> void:
	fire_cooldown = Tune.pickaxe_swing_every
	var hit := _pickaxe_hit()
	if hit.is_empty():
		return
	# Trees, rocks, and houses live under the "harvest" node.
	if hit.collider.get_parent().is_in_group("harvest"):
		material = mini(material + Tune.material_per_hit, Tune.max_material)
		Sfx.play_for_everyone("harvest", hit.position)


## Put the ghost wall on the 4 m grid, on the edge of your square that you face.
func _update_ghost() -> void:
	var grid := Tune.build_grid
	# Which way you face, snapped to north, east, south, or west.
	var forward := -cam_yaw.global_basis.z
	var dir := Vector3(signf(forward.x), 0, 0) if absf(forward.x) > absf(forward.z) else Vector3(0, 0, signf(forward.z))
	# The middle of the grid square you stand in.
	var cell := Vector3(floorf(global_position.x / grid) * grid + grid / 2.0, 0, floorf(global_position.z / grid) * grid + grid / 2.0)
	ghost.global_position = cell + dir * grid / 2.0 + Vector3(0, global_position.y + grid / 2.0, 0)
	ghost.global_rotation = Vector3(0, PI / 2.0 if dir.x != 0.0 else 0.0, 0)

	# Can I build here? Need enough material, and nothing already in the way.
	var shape := BoxShape3D.new()
	shape.size = Vector3(grid - 0.2, grid - 0.4, 0.15)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = ghost.global_transform.translated(Vector3(0, 0.1, 0))
	query.exclude = [get_rid()]
	var blocked := not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
	can_build = material >= Tune.wall_cost and not blocked
	ghost_mat.albedo_color = GHOST_OK if can_build else GHOST_NO


## Turn the ghost into a real wall: pay, then ask the host to build it.
func _place_wall() -> void:
	material -= Tune.wall_cost
	Net.tell_host(_ask_wall, ghost.global_transform)


## Runs on the host: make the wall on every screen.
func _ask_wall(spot: Transform3D) -> void:
	var walls := get_tree().current_scene.get_node("Walls")
	var wall: Node3D
	if Net.online:
		wall = Net.spawn_for_everyone(WALL_SCENE, walls)
	else:
		wall = WALL_SCENE.instantiate()
		walls.add_child(wall)
	wall.transform = spot # Walls sits at the middle of the world, so this is the same spot.
	Sfx.play_for_everyone("build", spot.origin)


func _unhandled_input(event: InputEvent) -> void:
	# Click to grab the mouse, Esc to let it go. (Not with touch controls: you need the pointer.)
	if event is InputEventMouseButton and event.pressed and not TouchControls.is_on():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Mouse look.
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(-event.relative * Tune.look_speed)


func _look(amount: Vector2) -> void:
	# Aiming slows the look so small moves are easier.
	if Input.is_action_pressed("aim"):
		amount *= Tune.aim_look_slow
	cam_yaw.rotate_y(amount.x)
	cam_pitch.rotation.x = clamp(cam_pitch.rotation.x + amount.y, deg_to_rad(-70), deg_to_rad(50))


func _physics_process(delta: float) -> void:
	# Gamepad look with the right stick.
	var stick := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if stick != Vector2.ZERO:
		_look(-stick * Tune.stick_look_speed * delta)

	# Slots: switch what is in your hand.
	if Input.is_action_just_pressed("slot_1"):
		slot = 1
	elif Input.is_action_just_pressed("slot_2") and has_rifle:
		slot = 2
	# Touch has no swap button: aim at a tree, rock, or house up close and
	# FIRE swings the pickaxe; anywhere else it fires the rifle.
	if TouchControls.is_on() and has_rifle:
		slot = 1 if _facing_harvest() else 2

	# Fire: hold the fire button to keep shooting bursts.
	# Build mode: Q turns it on and off. Picking a slot turns it off.
	if Input.is_action_just_pressed("build"):
		building = not building
	if Input.is_action_just_pressed("slot_1") or Input.is_action_just_pressed("slot_2"):
		building = false
	ghost.visible = building
	if building:
		_update_ghost()

	fire_cooldown -= delta
	if building:
		if Input.is_action_just_pressed("fire") and can_build:
			_place_wall()
	elif slot == 1 and Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
		_swing_pickaxe()
	elif slot == 2 and has_rifle and not reloading:
		if Input.is_action_pressed("fire") and fire_cooldown <= 0.0 and ammo > 0:
			_fire_burst()
		# Reload when you press the button, or by itself when empty.
		elif ammo < Tune.rifle_mag and (Input.is_action_just_pressed("reload") or (ammo == 0 and fire_cooldown <= 0.0)):
			_reload()

	# Heal: use a kit if you have one and are hurt. The host gives HP back bit by bit.
	if Input.is_action_just_pressed("heal") and heal_kits > 0 and heal_left <= 0.0 and hp < Tune.max_hp:
		heal_kits -= 1
		Net.tell_host(_ask_heal)

	# Aim: zoom the camera in smoothly while held, back out when let go.
	var target_fov := Tune.aim_fov if Input.is_action_pressed("aim") else Tune.normal_fov
	camera.fov = lerp(camera.fov, target_fov, 12.0 * delta)

	# Glide: sink at a steady speed until you touch the ground.
	if gliding and is_on_floor():
		gliding = false
	var speed := Tune.glide_steer if gliding else Tune.run_speed

	# Gravity pulls you down when you are in the air.
	if gliding:
		velocity.y = -Tune.glide_fall
	elif not is_on_floor():
		velocity.y -= Tune.gravity * delta

	# Jump: the speed you need to reach exactly Tune.jump_height.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = sqrt(2.0 * Tune.gravity * Tune.jump_height)

	# Read the move keys or left stick (-1 to 1 on each side).
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Turn the input so "forward" means "the way the camera looks".
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, cam_yaw.global_rotation.y)
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
