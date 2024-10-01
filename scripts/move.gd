extends HeroState

signal show_move_range
signal hero_move
signal hide_move_range 

func enter():
	print(owner.h_name + " 进入移动状态")
	emit_signal("show_move_range")

	
func handled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		emit_signal("hero_move")
		
func update(_delta: float) -> void:
	var current_id_path = Current.id_path
	if current_id_path.is_empty():
		return
	var target_tile = current_id_path.front()
	var target_tile_position = Vector2(target_tile.x * 32 + 16, target_tile.y * 32 + 16)
	owner.position = owner.position.move_toward(target_tile_position, 4)
	if global_position == target_tile_position:
		current_id_path.pop_front()
		if current_id_path.is_empty():
			Current.id_path.clear()
			hero_state_machine.transition_to("end")
	for key in Current.hero_dict:
		if Current.hero_dict[key] == Current.hero:
			Current.hero_dict.erase(key)
			Current.hero_dict[target_tile] = Current.hero

func exit():
	print(owner.h_name + " 离开移动状态")
	emit_signal("hide_move_range")
