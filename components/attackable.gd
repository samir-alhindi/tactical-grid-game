class_name Attackable extends Node

signal attacked(amount: int, direction: Grid.Directions)

func attack(amount: int, direction: Grid.Directions):
	attacked.emit(amount, direction)
