extends Node2D
class_name Hero

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hero_state_machine: HeroStateMachine = $hero_state_machine

var h_id: String
var h_name: String
var move_type: String
var move_distance: float
var grid_index: Vector2i

signal hero_cmd()

func _ready() -> void:
	var hero_icon_path = "res://sprites/" + h_id + ".png"
	print(hero_icon_path)
	sprite_2d.texture = load(hero_icon_path)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Current.hero == null:
		Current.hero = self	
		print("选中：" + h_name)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if Current.hero == self:
		if get_state() == "idle" or get_state() == "end":
			Current.hero = null	
			print("离开：" + h_name)

func get_state():
	return hero_state_machine.state.name

func set_state(state):
	hero_state_machine.transition_to(state)

func _on_move_show_move_range() -> void:
	emit_signal("hero_cmd", "show_move_range")

func _on_move_hero_move() -> void:
	emit_signal("hero_cmd", "hero_move")

func _on_move_hide_move_range() -> void:
	emit_signal("hero_cmd", "hide_move_range")
