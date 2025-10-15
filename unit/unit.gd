class_name Unit extends Path2D

signal walk_finished

@export var grid: Grid = preload("uid://cfjlunvnwemen")
@export var move_range := 6
@export var skin: Texture
@export var skin_offset := Vector2.ZERO 
@export var move_speed := 600.0

var cell := Vector2.ZERO:
	set = set_cell
var is_selected := false:
	set = set_is_selected
var is_walking := false:
	set = set_is_walking

func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		%AnimationPlayer.play("selected")
	else:
		%AnimationPlayer.play("idle")

func set_is_walking(value: bool) -> void:
	is_walking = value
	set_process(is_walking)

func _ready() -> void:
	set_process(false)
	%Sprite.texture = skin
	%Sprite.position = skin_offset
	# The following lines initialize the `cell` property and snap the unit to the cell's center on the map.
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	curve = Curve2D.new()

func walk_along(path: PackedVector2Array) -> void:
	if path.size() == 0:
		return
	curve.add_point(Vector2.ZERO)
	for point: Vector2 in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self.is_walking = true

func _process(delta: float) -> void:
	%PathFollow2D.progress += move_speed * delta
	if %PathFollow2D.progress_ratio >= 1.0:
		self.is_walking = false
		%PathFollow2D.progress_ratio = 0.0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		walk_finished.emit()
