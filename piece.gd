extends Sprite2D

class_name Piece

@export var BlueTex = preload("res://Graphics/blue piece.png")
@export var GreenTex = preload("res://Graphics/Green piece.png")
@export var RedTex = preload("res://Graphics/pink piece.png")
@export var YellowTex = preload("res://Graphics/Yellow piece.png")

var id : int

var bonded_id : int = 16

signal on_selection(p_id)

func set_id(num) -> void:
	id = num

func get_id() -> int:
	return id

func get_bonded_id() -> int:
	return bonded_id

func is_bonded() -> bool:
	if bonded_id == 16:
		return false
	else:
		return true

func bond_to(x:int) -> void:
	if x > 0 and x < 16:
		bonded_id = x
	elif x == 16:
		print(id, " unbonded manually from ", bonded_id)
		bonded_id = 16

func unbond() -> int:
	var b = bonded_id
	print(id, " unbonded from ", bonded_id)
	bonded_id = 16
	return b

func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_released("on_click"):
		await get_tree().process_frame
		emit_signal("on_selection", id)
