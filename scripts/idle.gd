extends HeroState

func enter():
	print(owner.h_name + " 进入空闲状态")
	
func handled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		hero_state_machine.transition_to("move")
