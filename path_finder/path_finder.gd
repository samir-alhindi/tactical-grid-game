class_name PathFinder extends RefCounted

const DIRECTIONS := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var grid: Resource
var astar := AStar2D.new()

func _init(new_grid: Grid, walkable_cells: PackedVector2Array) -> void:
	self.grid = new_grid
	var cell_mappings: Dictionary[Vector2,int] = {}
	for cell: Vector2 in walkable_cells:
		cell_mappings[cell] = grid.as_index(cell)
	_add_and_connect_points(cell_mappings)

## Returns the path found between `start` and `end` as an array of Vector2 coordinates.
func calculate_point_path(start: Vector2, end: Vector2) -> PackedVector2Array:
	var start_index: int = grid.as_index(start)
	var end_index: int = grid.as_index(end)
	if astar.has_point(start_index) and astar.has_point(end_index):
		return astar.get_point_path(start_index, end_index)
	else:
		return PackedVector2Array()

## Adds and connects the walkable cells to the Astar2D object.
func _add_and_connect_points(cell_mappings: Dictionary[Vector2,int]) -> void:
	for point: Vector2 in cell_mappings:
		astar.add_point(cell_mappings[point], point)
	
	for point: Vector2 in cell_mappings:
		for neighbor_index in _find_neighbor_indices(point, cell_mappings):
			astar.connect_points(cell_mappings[point], neighbor_index)

## Returns an array of the `cell`'s connectable neighbors.
func _find_neighbor_indices(cell: Vector2, cell_mappings: Dictionary) -> Array:
	var out := []
	for direction in DIRECTIONS:
		var neighbor: Vector2 = cell + direction
		if not cell_mappings.has(neighbor):
			continue
		if not astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbor]):
			out.push_back(cell_mappings[neighbor])
	return out
