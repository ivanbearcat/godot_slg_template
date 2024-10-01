extends Node2D

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"
@onready var grids: Node2D = $grids
@onready var cursor: CharacterBody2D = $cursor
@onready var map_01: Node2D = $".."
@onready var heros: Node2D = $heros

var astar_grid_2d: AStarGrid2D
const grid_size: Vector2i = Vector2i(32, 32)
const start_position: Vector2i = Vector2(0, 0)
const offset = [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0)]
var search_range: Vector2i
var grid_resourse: Resource = preload("res://prefabs/grid.tscn")
var hero_resourse: Resource = preload("res://prefabs/hero.tscn")
var map_dict: Dictionary


func _ready() -> void:
	init()
	
	
func _input(event: InputEvent) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	move_cursor(dir)
	
# 查询移动围	
func find_move_range(hero):
	var move_range: Array #移动范围
	var now_range: Dictionary #当前查询位置
	var target_range: Dictionary #根据now_range询到的目标位置
	var move_distance = hero.move_distance #当前单位移动距离
	var move_type = hero.move_type #当前单位移动类型
	# 第一次查询为当前单位所在的四个方向，剩余移动距离为当前单位可移动距离
	now_range[hero.grid_index] = move_distance
	# 使用移动距离进行遍历，当前地图移动至少消耗1，查询次数不会超过移动距离
	for i in range(move_distance):
		for now_key in now_range.keys():
			# 查询当前位置四个方向可移动的位置，now_key:当前位置，now_range[now_key]剩余可移动距离，move_type:移动类型,hero:当前单位
			var neighbours = find_neighbours_grid(now_key, now_range[now_key], move_type, hero)
			if neighbours != null:
				# 遍历查询出的位置信息，并将新的位置添加到最终的移动范围及下次查询目标中
				for key in neighbours.keys():
					# 已经在添加到移动范围的位置直接跳过
					if move_range.has(key):
						continue
					# 当前位置添加到移动范围
					move_range.append(key)
					# 添加到目标位置于下次循环
					target_range[key] = neighbours[key]
		# 清除已经遍历的位置
		now_range.clear()
		# 未查询到新的位置则跳出循环
		if target_range.is_empty():
			break
		# 将目标位置复制到当前位置，用于下次循环使用
		now_range = target_range.duplicate(true)
		# 清除目标范围字段
		target_range.clear()
	# 返回查询到的所有位置范围
	return move_range
	
# 查询当前位置上下左右四个方向可移动位置及剩余移动距离
func find_neighbours_grid(grid_index, move_distance, move_type, hero):
	var neighbours: Dictionary #传入位置上下左右可移动的位置集合
	# 遍历上下左右四个方向，进行判断是否可移动
	for i in range(offset.size()):
		# 当前位置相邻的格子位置
		var vector = grid_index + offset[i]
		# 判断vector位置是否超出地图可移动范围
		if vector.x >= 0 and vector.x <= (search_range.x- 1) and vector.y >= 0 and vector.y <= (search_range.y - 1):
			# 是否在地图内
			if map_dict.has(vector):
				# 计算敌方单位棋子阻挡，先判断当前位置是否存在棋子，再判断是否跟当前棋子同属一个队伍
				#if Current.enemy_dict.has(vector):
					#if Current.enemy_dict[vector].team != hero.team:
						#continue
				#elif Current.hero_dict.has(vector):
					#if Current.hero_dict[vector].team != hero.team:
						#continue
				# 获取当前地图快的数据
				var tile_data: TileData = tile_map_layer.get_cell_tile_data(vector)
				# 如果是墙或者获取不到地形类型则跳过循环
				if tile_data.get_custom_data("wall") or !tile_data.get_custom_data("move_cost"):
					continue
				# 根据当前单位移动类型获得当前地形移动距离消耗
				var move_cost = tile_data.get_custom_data("move_cost")[move_type]
				# 如果剩余移动距离大于等于当前地形消耗
				if move_distance >= move_cost:
					# 计算剩余移动距离及添加当前位置及移动到当前位置剩余移动距离
					var remainder_cost = move_distance - move_cost
					neighbours[vector] = remainder_cost
	return neighbours
				
					

func move_cursor(dir):
	var current_tile: Vector2i = tile_map_layer.local_to_map(cursor.position)
	var target_tile = Vector2i(current_tile.x + dir.x, current_tile.y + dir.y)
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(target_tile)
	if tile_data.get_custom_data("wall"):
		return
	var tween = create_tween()
	tween.tween_property(cursor, "position", tile_map_layer.map_to_local(target_tile), 0.09).set_trans(Tween.TRANS_SINE)
	#cursor.position = tile_map_layer.map_to_local(target_tile)


func init():
	# 获取地图大小
	var map_rect: Rect2i = tile_map_layer.get_used_rect()
	# 地图搜索范围等于地图大小
	search_range = map_rect.size - Vector2i(4, 4)
	# 循环遍历所有地图块x,y
	for x in range(search_range.x):
		for y in range(search_range.y):
			var grid = grid_resourse.instantiate()
			grid.grid_index = Vector2i(x, y)
			## 根据图块大小计算grid实际位置
			var pos_x = x * grid_size.x + start_position.x
			var pos_y = y * grid_size.y + start_position.y
			grid.position = Vector2i(pos_x, pos_y)
			grids.add_child(grid)
			map_dict[grid.grid_index] = grid
	# 通过json获取棋子信息
	var map_name = map_01.name
	var json_path = "res://data/" + map_name + ".json"
	var json_data = Util.load_json_file(json_path)
	var heros_data = json_data.hero
	for key in heros_data.keys():
		var hero_data = heros_data[key]
		var hero = hero_resourse.instantiate()
		set_hero_property(hero, hero_data)
		heros.add_child(hero)
		Current.hero_dict[hero.grid_index] = hero
	astar_grid_2d = AStarGrid2D.new()
	astar_grid_2d.region = map_rect
	astar_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_2d.update()	

func show_move_range():
	var hero = Current.hero
	Current.move_range = find_move_range(hero)
	for key in map_dict.keys():
		map_dict[key].range.visible = false
	for grid_index in Current.move_range:
		map_dict[grid_index].range.visible = true
	print(Current.hero.h_name , "显示移动范围")
	
func hide_move_range():
	for grid_index in Current.move_range:
		map_dict[grid_index].range.visible = false
	Current.move_range.clear()
	
func hero_move():
	# 是否已经在移动中
	if Current.id_path.size() > 0:
		return
	var hero = Current.hero
	var target_tile: Vector2i = tile_map_layer.local_to_map(cursor.position)
	# 判断目标位置不在移动围内或有其他棋子，则不能移动
	if !Current.move_range.has(target_tile) or Current.hero_dict.has(target_tile):
		return
	Current.id_path = astar_grid_2d.get_id_path(hero.grid_index, target_tile)
	print(Current.id_path)
	
	
func _on_hero_cmd(cmd_name):
	call(cmd_name)


func set_hero_property(hero: Hero, hero_data):
	var callable = Callable(self, "_on_hero_cmd")
	hero.connect("hero_cmd", callable)
	hero.h_id = hero_data.h_id
	hero.h_name = hero_data.h_name
	hero.move_type = hero_data.move_type
	hero.move_distance = hero_data.move_distance
	hero.grid_index = Vector2i(hero_data.x, hero_data.y)
	hero.position = Vector2i(hero_data.x * 32 + 16, hero_data.y * 32 + 16)
	
