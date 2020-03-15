extends Sprite

# Source code from Gonkee's 2D block-based lighting system - original video https://youtu.be/XgdAkqg7eKs

onready var player = get_parent().get_node("player")
onready var world_main = get_parent()

var light_radius = 8
var light_values = []

var temp_unlit_blocks = []

var size = Vector2()
var size_in_tiles = Vector2()

var snap_step = 128

var initialised = false

func _ready():

	for x in range(200):
		light_values.append([])
		for y in range(100):
			light_values[x].append(0)


	set_size()

func init_block_lights():
	for x in range(light_values.size()):
		for y in range(light_values[x].size()):
			if world_main.fg_tiles.get_cell(x, y) == -1:
				light_block(x, y, 1, 0)


func _process(delta):

	if not initialised:
		init_block_lights()
		initialised = true

	set_pos()

func remove_light_source(x, y):
	temp_unlit_blocks.clear()
	unlight_block(x, y, x, y)

	var to_relight = []
	for block in temp_unlit_blocks:
		for nx in range(block.x - 1, block.x + 2):
			for ny in range(block.y - 1, block.y + 2):
				if within_bounds(nx, ny) and light_values[nx][ny] > light_values[block.x][block.y] and not to_relight.has(Vector2(nx, ny)):
					to_relight.append(Vector2(nx, ny))

	for source in to_relight:
		light_block(source.x, source.y, light_values[source.x][source.y], 0)

	set_shader_tiles()


func unlight_block(x, y, ix, iy):
	if abs(x - ix) >= light_radius or abs(y - iy) >= light_radius or temp_unlit_blocks.has(Vector2(x, y)):
			return

	for nx in range(x - 1, x + 2):
		for ny in range(y - 1, y + 2):
			if nx != x or ny != y:
				if within_bounds(nx, ny) and light_values[nx][ny] < light_values[x][y]:
					unlight_block(nx, ny, ix, iy)

	light_values[x][y] = 0
	temp_unlit_blocks.append(Vector2(x, y))

func add_light_source(x, y):
	light_block(x, y, 1, 0)
	set_shader_tiles()

func light_block(x, y, intensity, iteration):
	if iteration >= light_radius:
		return

	light_values[x][y] = intensity

	var dropoff
	if world_main.fg_tiles.get_cell(x, y) == -1:
		dropoff = 0.9
	else:
		dropoff = 0.6

	for nx in range(x - 1, x + 2):
		for ny in range(y - 1, y + 2):
			if nx != x or ny != y:
				var dist = sqrt( (nx - x) * (nx - x) + (ny - y) * (ny - y) )
				var target_intensity = intensity * pow(dropoff, dist)
				if within_bounds(nx, ny) and light_values[nx][ny] < target_intensity:
					light_block(nx, ny, target_intensity, iteration + 1)


func set_size():
	size = get_viewport_rect().size + Vector2(snap_step, snap_step) * 2
	size *= player.get_node("camera").zoom
	size.x = stepify(size.x, 32)
	size.y = stepify(size.y, 32)

	size_in_tiles.x = int(size.x / 16)
	size_in_tiles.y = int(size.y / 16)

	scale = size

func set_pos():
	var pos_x = stepify(player.position.x, snap_step) - size.x / 2
	var pos_y = stepify(player.position.y, snap_step) - size.y / 2

	if Vector2(pos_x, pos_y) != position:
		position = Vector2(pos_x, pos_y)
		set_shader_tiles()


func within_bounds(x, y):
	return (x < light_values.size() and
			x >= 0 and
			y < light_values[x].size() and
			y >= 0)


func set_shader_tiles():

	var start_x = int(position.x / 16)
	var start_y = int(position.y / 16)

	var region_tile_info = []

	for y in range(start_y, start_y + size_in_tiles.y):
		for x in range(start_x, start_x + size_in_tiles.x):
			if within_bounds(x, y):
				region_tile_info.append(light_values[x][y] * 255)
			else:
				region_tile_info.append(255)

	var img = Image.new()
	img.create_from_data(size_in_tiles.x, size_in_tiles.y, false, Image.FORMAT_L8, region_tile_info)

	var tex = ImageTexture.new()
	tex.create_from_image(img)
	material.set_shader_param("light_values", tex)
