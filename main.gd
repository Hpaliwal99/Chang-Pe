extends Node2D

#TODO 
#make dev console for custom moves

#List of spaces for pieces to move, refer for Global postion
@export var Game_Spaces : Array[Marker2D]

@onready var Dice := $Dice
@onready var movesL: Label = $Moves
@onready var turn_label: Label = $TurnLabel


#Relative Location from respective bases
var Location : Array[int] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

var Blue1 : Sprite2D
var Blue2 : Sprite2D
var Blue3 : Sprite2D
var Blue4 : Sprite2D
var Green1 : Sprite2D
var Green2 : Sprite2D
var Green3 : Sprite2D
var Green4 : Sprite2D
var Red1 : Sprite2D
var Red2 : Sprite2D
var Red3 : Sprite2D
var Red4 : Sprite2D
var Yellow1 : Sprite2D
var Yellow2 : Sprite2D
var Yellow3 : Sprite2D
var Yellow4 : Sprite2D

var Offset_Vectors : Array[Vector2] = [Vector2(0,-15), Vector2(35, 0), Vector2(0, 15), Vector2(-35,0)]
enum Players {BLUE, GREEN, RED, YELLOW}
var active_piece = 0
var active_player : Players
var is_moving : bool
var Kills : Array[int] = [0,0,0,0]
var Promoted : Array[bool] = [false,false,false,false] #Stores the status of tod/ugradation
@onready var piece_list : Array[Piece] = [Blue1, Blue2, Blue3, Blue4, Green1, Green2, Green3, Green4, Red1, Red2, Red3, Red4, Yellow1, Yellow2, Yellow3, Yellow4]
@onready var timer := $Timer


#Sequence for each player to follow and to get global location
var Blue_Seq : Array[int] =   [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
var Green_Seq : Array[int] = [4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,22,23,16,17,18,19,20,21,24]
var Red_Seq : Array[int] =   [8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,20,21,22,23,16,17,18,19,24]
var Yellow_Seq : Array[int] =[12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,18,19,20,21,22,23,16,17,24]
var Seq_list = [Blue_Seq, Green_Seq, Red_Seq, Yellow_Seq]

func _ready() -> void:
	active_player = Players.BLUE
	
	movesL.label_settings.font_color = Color(0.627451, 0.12549, 0.941176, 1)
	turn_label.label_settings.font_color = Color(0.627451, 0.12549, 0.941176, 1)
	turn_label.text = "Turn: " + Players.keys()[active_player]
	
	#LOAD IT
	var Piece_load = preload("res://piece.tscn")
	
	# Instantiating all the pieces
	for i in range (16) :
		#INSTANCE IT
		piece_list[i] = Piece_load.instantiate()
		#ADD IT
		add_child(piece_list[i])
		#MAKE IT COMPLETE
		piece_list[i].set_id(i)
		match (i/4):
			0:
				piece_list[i].texture = piece_list[i].BlueTex
				piece_list[i].global_position = (Game_Spaces[0].position + (Offset_Vectors[i%4] * 3))
				piece_list[i].add_to_group("BLUE")
			1:
				piece_list[i].texture = piece_list[i].GreenTex
				piece_list[i].global_position = (Game_Spaces[4].position + (Offset_Vectors[i%4] * 3))
				piece_list[i].add_to_group("GREEN")
			2:
				piece_list[i].texture = piece_list[i].RedTex
				piece_list[i].global_position = (Game_Spaces[8].position + (Offset_Vectors[i%4] * 3))
				piece_list[i].add_to_group("RED")
			3:
				piece_list[i].texture = piece_list[i].YellowTex
				piece_list[i].global_position = (Game_Spaces[12].position + (Offset_Vectors[i%4] * 3))
				piece_list[i].add_to_group("YELLOW")
		
		piece_list[i].on_selection.connect(_on_selection_signal)

func _on_dice_on_dice_roll(roll: int) -> void:
	print(roll)
	
	movesL.set_text(str(roll))

func move(what: int, player : int) -> void:
	#add error reporting
	var tween = create_tween()
	match (player):
				0:
					tween.tween_property(piece_list[what], "position", Game_Spaces[Seq_list[player][Location[what]]].position + (Offset_Vectors[0] + Offset_Vectors[3]) * (1 + (what%4)), 0.3)
				1:
					tween.tween_property(piece_list[what], "position", Game_Spaces[Seq_list[player][Location[what]]].position + (Offset_Vectors[0] + Offset_Vectors[1]) * (1 + (what%4)), 0.3)
				2:
					tween.tween_property(piece_list[what], "position", Game_Spaces[Seq_list[player][Location[what]]].position + (Offset_Vectors[2] + Offset_Vectors[1]) * (1 + (what%4)), 0.3)
				3:
					tween.tween_property(piece_list[what], "position", Game_Spaces[Seq_list[player][Location[what]]].position + (Offset_Vectors[2] + Offset_Vectors[3]) * (1 + (what%4)), 0.3)
	#tween.tween_property(piece_list[what], "position", Game_Spaces[Seq_list[player][Location[what]]].position + (Offset_Vectors[2] + Offset_Vectors[3]) * (1 + (what%4)), 0.3)
	timer.start()
	await timer.timeout
	

func check_capture(roll) -> int:
	for i in range (16) :
		if active_piece/4 == i/4:
			if piece_list[i].is_bonded() == true:
				pass
			elif Promoted[active_piece/4] == true :
				if piece_list[active_piece].is_bonded() == false and ((Location[active_piece]%4 != 0 or Location[active_piece] >= 16)) and active_piece != i and (Location[active_piece] == Location[i]):
					piece_list[active_piece].bond_to(i)
					piece_list[i].bond_to(active_piece)
					print(active_piece, " bonded to ", i)
		elif (Location[active_piece]%4 == 0 and Location[active_piece] < 16):
			#Make this an option with ui
			if piece_list[active_piece].is_bonded():
				piece_list[piece_list[active_piece].unbond()].unbond()
			
		elif Seq_list[active_piece/4][Location[active_piece]] == Seq_list[i/4][Location[i]]:
			#checking if space is protected by bonded pair
			if piece_list[i].is_bonded() == true:
				if piece_list[active_piece].is_bonded():
					Capture(piece_list[i].bonded_id)
					piece_list[piece_list[i].unbond()].unbond()
				else:
					return 1
			Capture(i)
			return 1
	if roll != 4 and roll != 8 :
		return 0
	else:
		return 2

func Capture(c : int) -> int:
	print("Capture: ", active_piece, "->", c)
	#Promote Player pieces when successfully capturing a piece
	Promoted[active_piece/4] = true
	#print(Promoted)
	var x = (c/4)*4
	Kills[active_piece/4] += 1
	Location[c] = 0
	move(c, c/4)
	#Demote Player pieces when all land at base
	if Location[x] == 0 and Location[x+1] == 0 and Location[x+2] == 0 and Location[x+3] == 0:
		Promoted[c/4] = false
	return c

func _on_selection_signal(p_id: int) -> void:
	if is_moving or (p_id/4 != int(active_player)):
		return
	else:
		is_moving = true
	
	print(Players.find_key(p_id/4), p_id%4, " -> ID: ", p_id)
	var avai_moves = int(movesL.get_text())
	#print(avai_moves)
	active_piece = p_id
	if piece_list[active_piece].is_bonded():
		if avai_moves == 1 or avai_moves == 3:
			print("Invalid move")
			return
		else:
			avai_moves = avai_moves/2
	Location[active_piece] += avai_moves
	Location[active_piece] = Location[active_piece] % 25
	
	#Movement when Player not Promoted
	print((Promoted[active_piece/4]))
	if (Location[active_piece] > 15) and (Promoted[active_piece/4] == false):
		Location[active_piece] -= 16
		print("Rerouted")
	
	
	await move(active_piece, active_piece/4)
	if piece_list[active_piece].is_bonded() == true:
		Location[piece_list[active_piece].bonded_id] = Location[active_piece]
		print("Attempted to move ", piece_list[active_piece].bonded_id)
		await move(piece_list[active_piece].bonded_id, (piece_list[active_piece].bonded_id)/4)
	
	if Location[active_piece] == 24:
		piece_list[active_piece].get_child(0).visible = false
		print(Players.find_key(p_id/4), p_id%4, " reached Home!")
	
	#Game win condition
	var x = (active_piece/4)*4
	if Location[x] == 24 and Location[x+1] == 24 and Location[x+2] == 24 and Location[x+3] == 24:
		print(Players.find_key(active_piece/4), " has Won the game!")
	
	match check_capture(avai_moves):
		2:
			print("Extra Move: ", active_piece)
	
	is_moving = false

func Pass_Turn() -> int:
	#get_tree().set_group()
	active_player = (active_player + 1) % 4
	turn_label.text = "Turn: " + Players.keys()[active_player]
	return active_piece
