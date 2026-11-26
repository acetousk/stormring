class_name Fighter
extends CharacterBody3D
## Shared by the player and the bots: health, taking damage, and being out.

## Someone is out. `by` is who did it (can be null).
signal eliminated(who: Fighter, by: Fighter)

## Your health. At 0 you are out.
var hp := 100.0
## How many others you knocked out this match.
var eliminations := 0
## True once you are out.
var is_out := false


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


## Shooters call this. The host owns HP: other screens ask the host,
## the host takes the HP away, and HpSync sends the new HP to everyone.
func hurt(amount: float, by: Fighter) -> void:
	Net.tell_host(_ask_hurt, amount, str(by.get_path()) if by else "")


## Runs on the host.
func _ask_hurt(amount: float, by_path: String) -> void:
	var by: Fighter = get_node_or_null(by_path) if by_path != "" else null
	take_damage(amount, by)


## Runs on the host: take HP away. At 0 the host tells every screen you are out.
func take_damage(amount: float, by: Fighter) -> void:
	if is_out or out_sent:
		return
	hp = maxf(hp - amount, 0.0)
	print(name, " took ", amount, " from ", by.name if by else "?", " -> HP ", hp)
	if hp <= 0.0:
		out_sent = true
		Net.tell_everyone(_knocked_out, str(by.get_path()) if by else "")


## Runs on every screen: you are out. Each screen then checks who won.
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


## What happens when you are out. Bots and the player do this differently.
func _on_out() -> void:
	queue_free()
