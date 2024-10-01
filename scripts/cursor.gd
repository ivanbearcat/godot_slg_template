extends CharacterBody2D


@onready var tile_map_layer: TileMapLayer = $"../../TileMapLayer"
@onready var camera_2d: Camera2D = $Camera2D

const grid_size: Vector2i = Vector2i(32, 32)

func _ready() -> void:
	var map_rect: Rect2i = tile_map_layer.get_used_rect()
	camera_2d.limit_left = map_rect.position.x * grid_size.x
	camera_2d.limit_top = map_rect.position.y * grid_size.y
	camera_2d.limit_right = map_rect.position.x * grid_size.y + map_rect.size.x * grid_size.x
	camera_2d.limit_bottom = map_rect.position.y * grid_size.y + map_rect.size.y * grid_size.y
