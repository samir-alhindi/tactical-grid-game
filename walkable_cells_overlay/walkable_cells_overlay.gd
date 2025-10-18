## Draws an overlay over an array of cells.
class_name WalkableCellsOverlay extends TileMapLayer

func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cell(cell, 0, Vector2.ZERO, 0)
