class_name Gameboard extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
@export var grid: Grid = preload("uid://cfjlunvnwemen")

## Mapping of coordinates of a cell to a reference to the unit it contains.
var units: Dictionary[Vector2,Unit] = {}

func _ready() -> void:
	_reinitialize()

## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return true if units.has(cell) else false

## Clears, and refills the `units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	units.clear()
	
	for child: Node2D in get_children():
		var unit := child as Unit
		if not unit:
			continue
		units[unit.cell] = unit
	print(units)

## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> PackedVector2Array:
	var walkable_cells := []
	var stack := [cell]
	while not stack.is_empty():
		var current = stack.pop_back()
		
		if not grid.is_within_bounds(current):
			continue
		if current in walkable_cells:
			continue
		
		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue
		
		walkable_cells.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in walkable_cells:
				continue
		
			stack.append(coordinates)
	return walkable_cells
