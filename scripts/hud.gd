extends CanvasLayer
## The HUD: shows your HP, ammo, and heal kits on screen.

@onready var hp_label: Label = $HP
@onready var ammo_label: Label = $Ammo
@onready var heal_label: Label = $Heals
@onready var left_label: Label = $Left
@onready var end_box: Control = $End
@onready var storm_label: Label = $StormTimer
@onready var warning_label: Label = $StormWarning


func _ready() -> void:
	end_box.visible = false
	warning_label.visible = false


## Show the end-of-match message.
func show_end(title: String, stats: String, hint: String) -> void:
	$End/Title.text = title
	$End/Stats.text = stats
	$End/Hint.text = hint
	end_box.visible = true


func _process(_delta: float) -> void:
	# Everyone still in the match is in the "fighter" group.
	left_label.text = "Players left %d" % get_tree().get_nodes_in_group("fighter").size()
	# Online status: only in online matches (solo does not need the network).
	$NetStatus.visible = Net.online
	$NetStatus.text = Net.status

	# Storm timer, and a warning when you stand outside the circle.
	var storm := get_tree().get_first_node_in_group("storm")
	var player := get_tree().get_first_node_in_group("player")
	if storm:
		var secs := ceili(storm.time_left())
		var clock := "%d:%02d" % [floori(secs / 60.0), secs % 60]
		storm_label.text = ("Storm shrinking " if storm.shrinking else "Storm in ") + clock
		warning_label.visible = player != null and not player.is_out \
				and not storm.is_safe(player.global_position)
	if player == null:
		return
	hp_label.text = "HP %d" % ceili(player.hp)
	if player.heal_left > 0.0:
		hp_label.text += "  healing..."
	# What is in your hand.
	var rifle_text := "[2] Burst rifle" if player.has_rifle else "[2] empty - open a chest"
	if player.slot == 1:
		ammo_label.text = "> [1] Pickaxe   " + rifle_text
	elif player.reloading:
		ammo_label.text = "[1] Pickaxe   > [2] Reloading..."
	else:
		ammo_label.text = "[1] Pickaxe   > [2] Burst rifle  %d / %d" % [player.ammo, Tune.rifle_mag]
	heal_label.text = "Material  %d   Heal kits  %d" % [player.material, player.heal_kits]
