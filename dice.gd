extends Sprite2D

@onready var Dice_Ani : AnimationPlayer = $AnimationPlayer
signal on_dice_roll(roll)
var roll : int

@onready var timer := $Timer

func _ready() -> void:
	Dice_Ani.play("1")
	



func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	var Dane : Array[int] = [1,1,1,1,2,2,2,2,2,2,3,3,3,3,4,8]
	
	roll = Dane[randi() % 16]
	
	if Input.is_action_just_pressed("on_click"):
		Dice_Ani.play("Roll")
		timer.start(randf()*0.6)
		await timer.timeout
		Dice_Ani.pause()
		
		emit_signal("on_dice_roll", roll)
		
