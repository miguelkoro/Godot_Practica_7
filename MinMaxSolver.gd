extends VBoxContainer

const WIDTH = 4
const HEIGHT = 4
var gameOver: bool = false
@onready var currentState: BoardState = BoardState.new()
@export var init_depth = 4
@onready var arrayButtons: Array = [[$HBoxContainer_0/Button_0_0, $HBoxContainer_0/Button_0_1, $HBoxContainer_0/Button_0_2, $HBoxContainer_0/Button_0_3],
							[$HBoxContainer_1/Button_1_0, $HBoxContainer_1/Button_1_1, $HBoxContainer_1/Button_1_2, $HBoxContainer_1/Button_1_3],
							[$HBoxContainer_2/Button_2_0, $HBoxContainer_2/Button_2_1, $HBoxContainer_2/Button_2_2, $HBoxContainer_2/Button_2_3],
							[$HBoxContainer_3/Button_3_0, $HBoxContainer_3/Button_3_1, $HBoxContainer_3/Button_3_2, $HBoxContainer_3/Button_3_3]]
							
func get_lowest_empty_row(state: BoardState, col: int) -> int:
	for row in range(HEIGHT - 1, -1, -1): # de abajo a arriba
		if state.get_pos(row, col) == 0:
			return row
	return -1 # columna llena
	
#Funcion minmax con poda alfa, beta
	#Alfa = -infi
	#beta = +infi
func minimax(state: BoardState, depth: int, maximizing: bool, alpha: int, beta: int) -> int:
	var result := state.evaluate_win()
	#_print_board(state, false, depth, alpha, beta) Para mirar que va ahaciendo
	if result != 0:
		return result #Si devuelve que uno de los jugadores ha ganado, devuelve -1 o 1 siendo -1el jugadorr y 1 la ia

	if depth == 0 or state.is_full():
		return 0  # empate o ya no se puede ir mas profundo en el arbol

	if maximizing: #Nodo max, modioficamos el valor de alfa si es mayor 
		var max_eval := -999
		for col in range(WIDTH):
			var row := get_lowest_empty_row(state, col)
			if row == -1:
				continue
					
			var child := BoardState.new() #Creamos un tablero auxiliar y ponemos la jugada de la IA en la poscion que toque
			child.state = state.state.duplicate(true)
			child.set_pos(row, col, 1)
			
			#llamamos de forma recursiva al minmax para evaluar las ramas de abajo, poniendole un -1 al depth para que la profundida no pase del maximo
			#Le pasamos los valores alfa y beta, el tablero con el estado actual y como acabamos de maximizar, ahora minimizamos
			var eval := minimax(child, depth - 1, false, alpha, beta) 
			max_eval = max(max_eval, eval) #Se busca el mayor numero de entre -infi y eval (que eval será el max de todas las ramas inferiores)
			alpha = max(alpha, eval) #Alfa será el maximo de entre el anterior alfa y el max devuelto en el min
			
			if beta <= alpha: #si alfa es  mayor o igual  a beta, no hace falta seguir evaulando las siguientes ramas
				return max_eval #devolvemos el maximo al estar maximizando

		return max_eval
	else: #Min modificamos el valor de bta si es menor
		var min_eval := 999
		for col in range(WIDTH):
			var row := get_lowest_empty_row(state, col)
			if row == -1:
				continue

			var child := BoardState.new()
			child.state = state.state.duplicate(true)
			child.set_pos(row, col, -1) #Juega el jugador

			var eval := minimax(child, depth - 1, true, alpha, beta)
			min_eval = min(min_eval, eval) #Se busca el menor valor entre el devuelto en el max y +infi
			beta = min(beta, eval) #Beta será el minimo entre el valor devuelto y el beta anterior

			if beta <= alpha: #Si alfa es mayor o igual a beta, podemos hacer prunning
				return min_eval

		return min_eval

	
func activate_button(x: int, col: int):
	if gameOver:
		return

	var row := get_lowest_empty_row(currentState, col) #Mira si la columna esta completa
	if row == -1:
		return # columna llena, no hace nada

	# Turno jugador
	currentState.set_pos(row, col, -1) #Si no lo esta, se le pone el -1 del jugador
	update_visuals()

	var res := currentState.evaluate_win() #Evaluamos nuestra jugada, si sale -1, es que hemos ganado
	if res == -1:
		print("YOU WIN")
		gameOver = true
		return

	if currentState.is_full(): #Miramos si ya esta el tablero lleno y por tanto es empate
		print("EMPATE")
		gameOver = true
		return

	# Turno IA
	var ai_state := get_best_move(currentState)
	if ai_state == null: #Si devuelve null es que no hay mas posibles jugadas
		print("EMPATE")
		gameOver = true
		return

	currentState = ai_state #Ponemos como principal el board devuelto por la IA con la mejor jugada
	update_visuals()

	res = currentState.evaluate_win()
	if res == 1: #Si tras jugar la IA sale 1, es que ha agando
		print("YOU LOSE")
		gameOver = true
		return

	if currentState.is_full():
		print("EMPATE")
		gameOver = true

#LLamo primero a este metodo para inicizaliar el minmax y probar cada combinacion con un min
#basicamente simulamos el primer maximizar, no importa demasiado porque la poda se realiza a partid del segundo nivel
func get_best_move(state: BoardState) -> BoardState:
	var best_value := -999 #Simula el alfa,
	var best_state: BoardState = null
	for col in range(WIDTH):
		var row := get_lowest_empty_row(state, col)
		if row == -1:
			continue

		var child := BoardState.new() #Creamos una tabla auxiliar y colocamos el 1
		child.state = state.state.duplicate(true)
		child.set_pos(row, col, 1)

		var move_value := minimax(child, init_depth - 1, false, -999, 999)

		if move_value > best_value or best_state == null: #Si el movimiento es mejor que los anteriores o no hay ningun movimiento asignado
			best_value = move_value
			best_state = child #Ponemos esa tabla auziliar como la que tiene mejor posicion

	return best_state

func update_visuals ():
	for i in range(HEIGHT):
		for j in range(WIDTH):
			if currentState.get_pos(i,j) == -1:
				(arrayButtons[i][j] as Button).text = "X"
			elif currentState.get_pos(i, j) == 1:
				(arrayButtons[i][j] as Button).text = "0"
				
#Para hacer un poco de debug, luego lo comento
func _print_board(board: BoardState, maximizing: bool, depth: int, alpha: int, beta: int) ->void:
	if maximizing:
		print("MAX - " + "Alfa: " + str(alpha) + ", Beta: " + str(beta) + " - depth: " + str(depth) )
	else:
		print("MIN - " + "Alfa: " + str(alpha) + ", Beta: " + str(beta) + " - depth: " + str(depth) )
	for i in range(HEIGHT):
		var row = ""
		for j in range(WIDTH):
			if board.get_pos(i,j) == 0:
				row = row + "[ ]"
			elif board.get_pos(i,j) == 1:
				row = row + "[O]"
			else:
				row = row + "[X]"
		print(row)

## BOTOnES
func _on_button_0_0_pressed() -> void:
	activate_button(0,0)


func _on_button_0_1_pressed() -> void:
	activate_button(0,1)


func _on_button_0_2_pressed() -> void:
	activate_button(0,2)


func _on_button_0_3_pressed() -> void:
	activate_button(0,3)


func _on_button_1_0_pressed() -> void:
	activate_button(1,0)


func _on_button_1_1_pressed() -> void:
	activate_button(1,1)


func _on_button_1_2_pressed() -> void:
	activate_button(1,2)


func _on_button_1_3_pressed() -> void:
	activate_button(1,3)


func _on_button_2_0_pressed() -> void:
	activate_button(2,0)


func _on_button_2_1_pressed() -> void:
	activate_button(2,1)


func _on_button_2_2_pressed() -> void:
	activate_button(2,2)


func _on_button_2_3_pressed() -> void:
	activate_button(2,3)


func _on_button_3_0_pressed() -> void:
	activate_button(3,0)


func _on_button_3_1_pressed() -> void:
	activate_button(3,1)


func _on_button_3_2_pressed() -> void:
	activate_button(3,2)


func _on_button_3_3_pressed() -> void:
	activate_button(3,3)
