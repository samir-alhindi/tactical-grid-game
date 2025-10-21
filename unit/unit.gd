class_name Unit extends Path2D

signal turn_finished

@export var grid: Grid = preload("uid://cfjlunvnwemen")
@export var move_range := 6
@export var skin: Texture
@export var skin_offset := Vector2.ZERO 
@export var unit_name: StringName = "name here"
@export var move_speed := 600.0
@export var strength: int = 10
@export var health: int = 100

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
		select_option()

func select_option() -> void:
	var create_button := func(text: String, callable: Callable) -> void:
		var button := Button.new()
		%Options.add_child(button)
		button.text = text
		button.pressed.connect(callable)
	
	%UI.show()
	create_button.call("do nothing", func():
		%UI.hide()
		for child: Node in %Options.get_children():
			child.queue_free()
		turn_finished.emit()
		)
	
	var units: Dictionary[Unit, Vector2] = {}
	for dir: Vector2 in Grid.DIRECTIONS:
		var current := self.cell + dir
		if current in Gameboard.units:
			var unit: Unit = Gameboard.units[current]
			if unit.has_method("on_attacked"):
				units[unit] = dir
	
	for unit: Unit in units:
		create_button.call("attack "+unit.unit_name, func():
			unit.on_attacked(strength, units[unit])
			%UI.hide()
			for child: Node in %Options.get_children():
				child.queue_free()
			turn_finished.emit()
			)

func on_attacked(amount: int, direction: Vector2) -> void:
	var tween := create_tween()#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	var og_pos := position
	var new_pos = grid.calculate_map_position(cell + direction)
	tween.tween_property(self, "position", new_pos, 0.2)
	tween.tween_property(self, "position", og_pos, 0.1)
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	Gameboard.units.erase(cell)
	queue_free()
