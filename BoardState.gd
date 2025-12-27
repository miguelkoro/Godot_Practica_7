class_name BoardState

var state := [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]

func get_pos(x:int, y:int)->int:
	return state[x][y]
	
func set_pos(x:int, y:int, value:int)->void:
	state[x][y] = value

func is_full() -> bool:
	for i in range(4):
		for j in range(4):
			if state[i][j] == 0:
				return false
	return true

	
func evaluate_win()->int: #-1, 0 or 1.
	
	var victory:bool
	#Horizontal test
	#[x][x][x][x]
	#[ ][ ][ ][ ]
	#[ ][ ][ ][ ]
	#[ ][ ][ ][ ]
	
	for i in range(4):
		victory= state[i][0] == state[i][1] && state[i][1] == state[i][2] && state[i][2] == state[i][3] 
		if victory && state[i][0]!=0:
			return state[i][0]
			
	#Vertical test
	#[x][ ][ ][ ]
	#[x][ ][ ][ ]
	#[x][ ][ ][ ]
	#[ ][ ][ ][ ]
	for i in range(4):
		victory = state[0][i] == state[1][i] && state[1][i] == state[2][i] && state[2][i] == state[3][i]
		if victory && state[0][i]!=0:
			return state[0][i]

			
	#Diagonales
	#[x][ ][ ][ ]
	#[ ][x][ ][ ]
	#[ ][ ][x][ ]
	#[ ][ ][ ][x]
	victory = state[0][0] == state[1][1] && state[1][1] == state[2][2] && state[2][2] == state[3][3]
	if victory && state[1][1]!=0:
		return state[1][1]

	
	#[ ][ ][ ][x]
	#[ ][ ][x][ ]
	#[ ][x][ ][ ]
	#[x][ ][ ][ ]
	victory = state[0][3] == state[1][2] && state[1][2] == state[2][1] && state[2][1] == state[3][0]
	if victory && state[1][2]!=0:
		return state[1][2]
		
	return 0
