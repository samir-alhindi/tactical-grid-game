class_name Gameboard extends Node2D

@export var grid: Grid = preload("uid://cfjlunvnwemen")

## Mapping of coordinates of a cell to a reference to the unit it contains.
static var units: Dictionary[Vector2,Unit] = {}
var active_unit: Unit
var walkable_cells := []

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
		for direction in Grid.DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in walkable_cells:
				continue
		
			stack.append(coordinates)
	return walkable_cells

func select_unit(cell: Vector2) -> void:
	if not units.has(cell):
		return
	active_unit = units[cell]
	active_unit.is_selected = true
	walkable_cells = get_walkable_cells(active_unit)
	%WalkableCellsOverlay.draw(walkable_cells)
	%UnitPath.initialize(walkable_cells)

func deselect_active_unit() -> void:
	active_unit.is_selected = false
	%WalkableCellsOverlay.clear()
	%UnitPath.stop()

func clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()

func move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in walkable_cells:
		return
	units.erase(active_unit.cell)
	units[new_cell] = active_unit
	deselect_active_unit()
	active_unit.walk_along(%UnitPath.current_path)
	await active_unit.turn_finished
	clear_active_unit()

func _on_cursor_moved(new_cell: Vector2i) -> void:
	if active_unit and active_unit.is_selected:
		%UnitPath.draw(active_unit.cell, new_cell)


func _on_cursor_accept_pressed(cell: Vector2i) -> void:
	if not active_unit:
		select_unit(cell)
	elif active_unit.is_selected:
		move_active_unit(cell)

func _unhandled_input(event: InputEvent) -> void:
	if active_unit and event.is_action_pressed("ui_cancel"):
		deselect_active_unit()
		clear_active_unit()
