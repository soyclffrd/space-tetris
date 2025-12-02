extends Node2D

var i_tetromino: Array = [
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], # 90 degrees
	[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]  # 270 degrees
]
 
var t_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var o_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]  # All rotations are the same
]
 
var z_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]  # 270 degrees
]
 
var s_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 90 degrees
	[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var l_tetromino: Array = [
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var j_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]  # 270 degrees
]

var tetrominoes: Array = [i_tetromino, t_tetromino, o_tetromino, z_tetromino, s_tetromino, l_tetromino, j_tetromino]
var all_tetrominoes: Array = tetrominoes.duplicate()

const COLS: int = 10
const ROWS: int = 20

const START_POSITION: Vector2i = Vector2i(5, 1)
const movement_direction: Array[Vector2i] = [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
var current_positon: Vector2i
var fall_timer: float = 0
var fall_interval: float = 1.0
var fast_fall_multiplier: float = 10.0
var min_fall_interval: float = 0.05  # cap so fall_interval never gets too small

var current_tetromino_type: Array
var next_tetromino_type: Array
var rotation_index: int = 0
var active_tetromino: Array = []

var level: int = 1
var lines_cleared: int = 0
var level_speed_factor: float = 0.85
var burst_active: bool = false
var burst_timer: float = 0.0
var burst_duration: float = 2.0
var burst_chance: float = 0.10  

var score: int
const CLEAR_REWARD: int = 5
var is_game_running: bool
var title_id: int = 0
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

@onready var board_layer: TileMapLayer = $Board
@onready var active_layer: TileMapLayer = $Active

func _ready() -> void:
	start_new_game()
	$GameHUD/StartGameButton.visible = false
	$BackgroundMusic.play()

func start_new_game() -> void:
	score = 0
	level = 0
	lines_cleared = 0
	fall_interval = 1.0
	$GameHUD/Level.text = "Level " + str(level)
	$GameHUD/Score.text = "Score: " + str(score)
	$GameHUD/GameOver.visible = false
	$GameHUD/StartGameButton.visible = false
	is_game_running = true
	clear_tetromino()
	clear_board()
	clear_next_tetromino_preview()
	current_tetromino_type = choose_tetromino()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino_type), 0)
	next_tetromino_type = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino_type), 0)
	initialize_tetromino()
	
func _physics_process(delta: float) -> void:
	if is_game_running:
		var move_direction = Vector2i.ZERO
		
		if Input.is_action_just_pressed("ui_left"):
			move_direction = Vector2i.LEFT
		elif Input.is_action_just_pressed("ui_right"):
			move_direction = Vector2i.RIGHT

		if move_direction != Vector2i.ZERO:
			move_tetromino(move_direction)
			
		if Input.is_action_just_pressed("ui_up"): 
			rotate_tetromino()
			
		var current_fall_interval = fall_interval
		if Input.is_action_pressed("ui_down"):
			current_fall_interval /= fast_fall_multiplier
			
		# apply burst if active (temporary very fast fall)
		if burst_active:
			current_fall_interval /= 6.0
			burst_timer -= delta
			if burst_timer <= 0:
				burst_active = false

		fall_timer += delta
		if fall_timer >= current_fall_interval:
			move_tetromino(Vector2i.DOWN)
			fall_timer = 0

func choose_tetromino() -> Array:
	var selected_tetromino: Array	
	if not tetrominoes.is_empty():
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	else: 
		tetrominoes = all_tetrominoes.duplicate()
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	return selected_tetromino
	
func initialize_tetromino() -> void:
	current_positon = START_POSITION
	active_tetromino = current_tetromino_type[rotation_index]
	render_tetromino(active_tetromino, current_positon, piece_atlas)
	render_tetromino(next_tetromino_type[0], Vector2i(15, 2), next_piece_atlas)

func render_tetromino(tetromino: Array, position: Vector2i, atlas: Vector2i) -> void:
	for block in tetromino:
		active_layer.set_cell(position + block, title_id, atlas)
		
func clear_tetromino() -> void:
	for block in active_tetromino:
		active_layer.erase_cell(current_positon + block)

func rotate_tetromino() -> void:
	if is_valid_rotation():
		clear_tetromino()
		rotation_index = (rotation_index - 1) % 4
		active_tetromino = current_tetromino_type[rotation_index]
		render_tetromino(active_tetromino, current_positon, piece_atlas)

func move_tetromino(direction: Vector2i) -> void:
	if is_valid_move(direction):
		clear_tetromino()
		current_positon += direction
		render_tetromino(active_tetromino, current_positon, piece_atlas)
	else:
		if direction == Vector2i.DOWN:
			land_tetromino()
			check_rows()
			current_tetromino_type = next_tetromino_type
			piece_atlas = next_piece_atlas
			next_tetromino_type = choose_tetromino()
			next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino_type), 0)
			clear_next_tetromino_preview()
			initialize_tetromino()
			is_game_over()

func land_tetromino() -> void:
	for i in active_tetromino:
		active_layer.erase_cell(current_positon + i)
		board_layer.set_cell(current_positon + i, title_id, piece_atlas)
		
func clear_next_tetromino_preview() -> void:
	for i in range(14, 19):
		for j in range(2, 6):
			active_layer.erase_cell(Vector2i(i,j))

func level_up() -> void:
	level += 1
	# make fall interval faster but never below min_fall_interval
	fall_interval = max(min_fall_interval, fall_interval * level_speed_factor)
	$GameHUD/Level.text = "Level " + str(level)
	# optional: you can flash or animate the Level label here if desired

func check_rows() -> void:
	var row: int = ROWS

	while row > 0:
		var cells_filled: int = 0

		for i in range(COLS):
			if not is_within_bounds(Vector2i(i + 1, row)):
				cells_filled += 1

		if cells_filled == COLS:
			shift_rows(row)

			# scoring
			score += CLEAR_REWARD
			$GameHUD/Score.text = "Score: " + str(score)

			# keep track of cleared lines
			lines_cleared += 1

			# LEVEL UP every +10 SCORE
			while score / 10 >= level:
				level_up()

		else:
			row -= 1

func shift_rows(row) -> void:
	var atlas: Vector2i
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = board_layer.get_cell_atlas_coords(Vector2i(j + 1, i - 1))
			if atlas == Vector2i(-1, -1):
				board_layer.erase_cell(Vector2i(j + 1, i))
			else:
				board_layer.set_cell(Vector2i(j + 1, i), title_id, atlas)

func clear_board() -> void:
	for i in range(ROWS):
		for j in range(COLS):
			board_layer.erase_cell(Vector2i(j + 1, i + 1))

func is_valid_move(new_position: Vector2i) -> bool:
	for block in active_tetromino:
		if not is_within_bounds(current_positon + block + new_position):
			return false
	return true
	
func is_valid_rotation() -> bool:
	var next_rotation = (rotation_index + 1) % 4
	var rotated_tetromino = current_tetromino_type[next_rotation]
	
	for block in rotated_tetromino:
		if not is_within_bounds(current_positon + block):
			return false
	return true
	
func is_within_bounds(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= COLS + 1 or pos.y < 0 or pos.y >= ROWS + 1:
		return false
		
	var tile_id = board_layer.get_cell_source_id(pos)
	return tile_id == -1

func is_game_over() -> void:
	for i in active_tetromino:
		if not is_within_bounds(i + current_positon):
			land_tetromino()
			$GameHUD/GameOver.visible = true
			$GameHUD/StartGameButton.visible = true
			$GameHUD/StartGameButton.pressed.connect(start_new_game)
			is_game_running = false
