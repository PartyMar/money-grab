extends Node2D


@export_category("Basic parameters")
@export var map_size: Vector2i = Vector2i(20, 20)
@export var enemy_amount: int = 2
@export var enemy_spawn_distance: int = 5
@export var coins_amount: int = 10
@export var coins_spawn_distance: int = 5

@export_category("Noise generation parameters")
@export var noise_frequency: float = 0.2
@export var noise_octaves: int = 4
@export var block_threshold: float = 0.5
@export var object_noise_frequency: float = 0.08
@export var coin_noise_threshold: float = 0.0
@export var enemy_noise_threshold: float = -0.5

var coin_scene: PackedScene = preload("res://Scenes/Objects/coin.tscn")
var enemy1_scene: PackedScene = preload("res://Scenes/Objects/enemy1.tscn")
var block_scene: PackedScene = preload("res://Scenes/Objects/tile_block.tscn")
var player_scene: PackedScene = preload("res://Scenes/Player/player.tscn")

var terrain_noise: FastNoiseLite
var object_noise: FastNoiseLite

# Patterns for spawn objects (only for coins now)
var coin_patterns: Array = [
	[[0, 1, 0], [1, 1, 1], [0, 1, 0]],
	[[1, 1, 1], [0, 0, 0], [0, 0, 0]]
]

var map: Array
var player_pos: Vector2i

# variables for counts
var placed_coins: int = 0
var placed_enemies: int = 0


func _ready() -> void:
	if SaveManager.save_loading == false:
		generate_map()
	else:
		SaveManager.save_loading = false
		load_map()


func load_map() -> void:
	var data: SaveData = SaveManager.save_data
	
	GameManager.coins_amount = data.coins_amount
	GameManager.coins_count = data.coins_count
	
	for node in data.saved_objects:
		var node_instance = node.instantiate()
		self.add_child(node_instance)


func generate_map() -> void:
	# generate seed and noise
	var random_seed = randi()
	
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = random_seed
	terrain_noise.frequency = noise_frequency
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.fractal_octaves = noise_octaves

	object_noise = FastNoiseLite.new()
	object_noise.seed = random_seed + 1
	object_noise.frequency = object_noise_frequency
	object_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	GameManager.coins_amount = coins_amount
	placed_coins = 0
	placed_enemies = 0
	
	# Initialize map
	map = []
	for x in range(map_size.x):
		map.append([])
		for y in range(map_size.y):
			var noise_value = terrain_noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2  # 0..1
			map[x].append(noise_value > block_threshold)  # true = блок
	
	var new_map: Array = map.duplicate(true)
	for x in range(map_size.x):
		for y in range(map_size.y):
			var neighbors = count_neighbors(x, y)
			if map[x][y]:
				if neighbors < 3:
					new_map[x][y] = false
	map = new_map
	
	var empty_cells: Array = []
	for x in range(map_size.x):
		for y in range(map_size.y):
			if map[x][y]:
				var block = block_scene.instantiate()
				block.position = Vector2(x * 16, y * 16)
				add_child(block)
			else:
				empty_cells.append(Vector2i(x, y))
	
	# Place player and all around it
	var possible_player_pos: Array = []
	for pos in empty_cells:
		if has_clearance(pos.x, pos.y):
			possible_player_pos.append(pos)
	
	if possible_player_pos.size() > 0:
		possible_player_pos.shuffle()
		player_pos = possible_player_pos[0]
	else:
		empty_cells.shuffle()
		player_pos = empty_cells[0]
	
	var player = player_scene.instantiate()
	player.position = Vector2(player_pos.x * 16, player_pos.y * 16)
	add_child(player)
	#print("Player placed at: ", player_pos)
	
	empty_cells.erase(player_pos)
	var occupied_cells: Array = [player_pos]
	var reachable_empty: Array = get_reachable_cells(player_pos)
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			if randf() > 0.8:
				var obj_noise_value = object_noise.get_noise_2d(x, y)
				if obj_noise_value > coin_noise_threshold and \
				placed_coins < coins_amount:
					placed_coins += spawn_coin_pattern(
						coin_patterns[randi() % coin_patterns.size()],
						Vector2i(x, y),
						coin_scene,
						reachable_empty,
						occupied_cells
					)
				if obj_noise_value < enemy_noise_threshold and \
				placed_enemies < enemy_amount:
					if place_enemy(
						Vector2i(x, y),
						enemy1_scene,
						reachable_empty,
						occupied_cells,
						):
						placed_enemies += 1
						occupied_cells.append(Vector2i(x, y))
	
	reachable_empty.shuffle()
	var fallback_index: int = 0
	while placed_coins < coins_amount and fallback_index < reachable_empty.size():
		var pos = reachable_empty[fallback_index]
		if pos != player_pos and not occupied_cells.has(pos):
			var coin = coin_scene.instantiate()
			coin.position = Vector2(pos.x * 16, pos.y * 16)
			add_child(coin)
			occupied_cells.append(pos)
			placed_coins += 1
		fallback_index += 1
	
	while placed_enemies < enemy_amount and fallback_index < reachable_empty.size():
		var pos = reachable_empty[fallback_index]
		if pos != player_pos and not occupied_cells.has(pos) and \
		manhattan_distance(pos, player_pos) >= enemy_spawn_distance:
			var enemy = enemy1_scene.instantiate()
			enemy.position = Vector2(pos.x * 16, pos.y * 16)
			add_child(enemy)
			occupied_cells.append(pos)
			placed_enemies += 1
		fallback_index += 1
	
	#print("Placed coins: ", placed_coins, "/", coins_amount)
	#print("Placed enemies: ", placed_enemies, "/", enemy_amount)
	#print("Empty cells: ", empty_cells.size())
	#print("Reachable empty: ", reachable_empty.size())


func count_neighbors(x: int, y: int) -> int:
	var count: int = 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0: continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and \
			nx < map_size.x and \
			ny >= 0 and \
			ny < map_size.y and \
			map[nx][ny]:
				count += 1
	return count


func has_clearance(x: int, y: int) -> bool:
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0: continue
			var nx = x + dx
			var ny = y + dy
			if nx < 0 or nx >= map_size.x or ny < 0 or ny >= map_size.y:
				return false
			if map[nx][ny]:
				return false
	return true


func get_reachable_cells(start_pos: Vector2i) -> Array:
	var reachable: Array = []
	var visited: Dictionary = {}
	var queue: Array = [start_pos]
	visited[str(start_pos.x) + "_" + str(start_pos.y)] = true
	
	var dirs: Array = [
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 0),
		Vector2i(-1, 0)
		]
	
	while queue.size() > 0:
		var cur: Vector2i = queue.pop_front()
		reachable.append(cur)
		
		for dir in dirs:
			var nx: int = cur.x + dir.x
			var ny: int = cur.y + dir.y
			var key: String = str(nx) + "_" + str(ny)
			
			if nx >= 0 and \
			nx < map_size.x and \
			ny >= 0 and \
			ny < map_size.y and \
			not map[nx][ny] and \
			not visited.has(key):
				visited[key] = true
				queue.append(Vector2i(nx, ny))
	
	return reachable


func spawn_coin_pattern(
	pattern: Array,
	start_pos: Vector2i,
	scene: PackedScene,
	reachable_empty: Array,
	occupied_cells: Array
) -> int:
	var added: int = 0
	for px in range(pattern.size()):
		for py in range(pattern[px].size()):
			if pattern[px][py] == 1 and placed_coins + added < coins_amount:
				var pos_x = start_pos.x + px
				var pos_y = start_pos.y + py
				var pos = Vector2i(pos_x, pos_y)
				
				if pos_x >= 0 and \
				pos_x < map_size.x and \
				pos_y >= 0 and pos_y < map_size.y and \
				not map[pos_x][pos_y] and \
				reachable_empty.has(pos) and \
				not occupied_cells.has(pos) and \
				manhattan_distance(pos, player_pos) >= coins_spawn_distance:
					var instance = scene.instantiate()
					instance.position = Vector2(pos_x * 16, pos_y * 16)
					add_child(instance)
					occupied_cells.append(pos)
					added += 1
	return added


func place_enemy(
	pos: Vector2i,
	scene: PackedScene,
	reachable_empty: Array,
	occupied_cells: Array,
) -> bool:
	if placed_enemies >= enemy_amount:
		return false
	
	if not map[pos.x][pos.y] and \
	reachable_empty.has(pos) and \
	not occupied_cells.has(pos) and \
	manhattan_distance(pos, player_pos) >= enemy_spawn_distance:
		var instance = scene.instantiate()
		instance.position = Vector2(pos.x * 16, pos.y * 16)
		add_child(instance)
		return true
	else:
		return false


# util for calculating distance
func manhattan_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)
