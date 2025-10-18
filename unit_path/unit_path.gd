class_name UnitPath extends TileMapLayer

@export var grid: Grid = preload("uid://cfjlunvnwemen")

var pathfinder: PathFinder
var current_path := PackedVector2Array()

func initialize(walkable_cells: Array) -> void:
	pathfinder = PathFinder.new(grid, walkable_cells)

## Finds and draws the path between `cell_start` and `cell_end`.
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	current_path = pathfinder.calculate_point_path(cell_start, cell_end)
	for cell: Vector2 in current_path:
		set_cell(cell, 0, Vector2.ZERO, 0)
	set_cells_terrain_path(current_path, 0, 0)

## Stops drawing, clearing the drawn path and the `pathfinder`.
func stop() -> void:
	pathfinder = null
	clear()
