extends Node2D
class_name Pathfinding


var astar = AStar2D.new()
var tilemap: TileMap
var half_cell_size: Vector2
var used_rect: Rect2

func _physics_process(_delta):
	update_navigation_map()


func create_navigation_map(tilemap_temp: TileMap):
	self.tilemap = tilemap_temp
	half_cell_size = tilemap.tile_set.tile_size / 2
	used_rect = tilemap.get_used_rect()
	
	var tiles = tilemap.get_used_cells(0)
	add_traversable_tiles(tiles)
	connect_traversable_tiles(tiles)
	
	
func add_traversable_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id_for_point(tile)
		astar.add_point(id,tile)
	
func connect_traversable_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id_for_point(tile)
		
		for x in range(3):
			for y in range(3):
				var target = tile + Vector2i(x - 1, y - 1)
				var target_id = get_id_for_point(target)
				
				if tile == target or not astar.has_point(target_id):
					continue
				
				astar.connect_points(id, target_id, true)

func update_navigation_map():
	for point in astar.get_point_ids():
		astar.set_point_disabled(point, false)
	
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	
	for obstacle in obstacles:
		if obstacle is TileMap:
			var tiles = obstacle.get_used_cells(0)
			for tile in tiles:
				var id = get_id_for_point(tile)
				if astar.has_point(id):
					astar.set_point_disabled(id, true)
		if obstacle is CharacterBody2D:
			var tile_coord = tilemap.local_to_map(obstacle.collision_shape.global_position)
			var id = get_id_for_point(tile_coord)
			if astar.has_point(id):
				astar.set_point_disabled(id, true)
			
func get_id_for_point(point: Vector2):
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y
	
	return x + y * used_rect.size.x
	
func get_new_path(start: Vector2, end: Vector2) -> Array:
	var start_local = tilemap.to_local(start)
	var end_local = tilemap.to_local(end)
	
	var start_tile = tilemap.local_to_map(start_local)
	var end_tile = tilemap.local_to_map(end_local)
	
	var start_id = get_id_for_point(start_tile)
	var end_id = get_id_for_point(end_tile)
	
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return []
	
	var path_map = astar.get_point_path(start_id, end_id)
	
	var path_global = []
	for point in path_map:
		var point_local = tilemap.map_to_local(point)
		var point_global = tilemap.to_global(point_local)
		path_global.append(point_global)
	
	return path_global
