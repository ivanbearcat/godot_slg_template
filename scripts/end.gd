extends HeroState

func enter():
	print(owner.h_name + " 进入结束状态")
	owner.sprite_2d.material.set_shader_parameter("is_end", true)
