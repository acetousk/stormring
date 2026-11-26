class_name Fighter
extends CharacterBody3D
## Shared by the player and the bots: the clean meter, getting splatted, and being out.

## Someone is splatted (out of the round). `by` is who did it (can be null).
signal eliminated(who: Fighter, by: Fighter)

const TOMATO := Color(0.902, 0.224, 0.275) ## The shirt turns this color as you get messy

## How clean you are. At 0 you are splatted. (The name "hp" is short for "health points".)
## When it changes (here, or from the host by HpSync), the shirt color changes too.
var hp := 100.0:
	set(value):
		hp = value
		_show_mess()
## How many others you splatted this match.
var eliminations := 0
## True once you are splatted.
var is_out := false

## My own copy of the shirt color, so only my shirt turns red.
var shirt_mat: StandardMaterial3D
var shirt_color := Color.WHITE


## True once the host has said "you are out" (so it only says it once).
var out_sent := false


## Before MoveSync starts: set how often my spot is sent (from Tune).
func _enter_tree() -> void:
	var move_sync := get_node_or_null("MoveSync")
	if move_sync:
		move_sync.refresh_rate = Tune.net_send_rate
		move_sync.interpolation_speed = float(Tune.net_send_rate)
		# Local mode has no key, and GD-Sync's quick (unreliable) messages need one
		# (else: thousands of "Key must not be empty" errors). Use sure messages there.
		move_sync.reliable = Net.is_local()


## Call this from _ready: lets the host tell every screen that I am out.
## ("_ask_" requests go through Net.tell_host, so they need no allow.)
func _net_ready() -> void:
	Net.allow(_knocked_out, true)
	# The shirt is the "Torso" part of the model.
	var torso := get_node_or_null("Body/Torso") as MeshInstance3D
	if torso:
		shirt_mat = torso.get_active_material(0).duplicate()
		shirt_color = shirt_mat.albedo_color
		torso.material_override = shirt_mat
	_show_mess()


## Clean = the shirt's own color. Messy = more tomato red.
func _show_mess() -> void:
	if shirt_mat:
		var mess := 1.0 - clampf(hp / Tune.max_hp, 0.0, 1.0)
		shirt_mat.albedo_color = shirt_color.lerp(TOMATO, mess * 0.85)


## A tomato calls this when it splats on me. The host owns HP: other screens ask the host,
## the host takes the clean away, and HpSync sends the new value to everyone.
func hurt(amount: float, by: Fighter) -> void:
	Net.tell_host(_ask_hurt, amount, str(by.get_path()) if by else "")


## Runs on the host.
func _ask_hurt(amount: float, by_path: String) -> void:
	var by: Fighter = get_node_or_null(by_path) if by_path != "" else null
	take_damage(amount, by)


## Runs on the host: make me less clean. At 0 the host tells every screen I am splatted.
func take_damage(amount: float, by: Fighter) -> void:
	if is_out or out_sent:
		return
	hp = maxf(hp - amount, 0.0)
	print(name, " took ", amount, " from ", by.name if by else "?", " -> clean ", hp)
	if hp <= 0.0:
		out_sent = true
		Net.tell_everyone(_knocked_out, str(by.get_path()) if by else "")


## Runs on every screen: you are splatted. Each screen then checks who won.
func _knocked_out(by_path: String) -> void:
	if is_out:
		return
	is_out = true
	hp = 0.0
	remove_from_group("fighter")
	var by: Fighter = get_node_or_null(by_path) if by_path != "" else null
	if by:
		by.eliminations += 1
	eliminated.emit(self, by)
	_on_out()


## What happens when you are splatted. Bots and the player do this differently.
func _on_out() -> void:
	queue_free()
