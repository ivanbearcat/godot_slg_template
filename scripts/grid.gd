extends Node2D

@onready var range: Sprite2D = $range

var grid_index: Vector2i

func _on_area_2d_mouse_entered() -> void:
	pass
	#print("grid_index: ", grid_index)
