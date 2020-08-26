extends TileMap

var dirt  : int = tile_set.find_tile_by_name("dirt")
var stone : int = tile_set.find_tile_by_name("stone")
var ore   : int = tile_set.find_tile_by_name("ore")
var wall  : int = tile_set.find_tile_by_name("wall")

var seed_hash : int = "some_str".hash()

func _ready():
	add_island(210, 120)


func rand2D(x : int, y : int) -> float:
	return fposmod(sin(Vector2(x, y).dot(Vector2(12.9898,78.233))) * (43758.5453 + seed_hash % 100000), 1)

func noise2D(x : float, y : float, octaves : int) -> float:
	if octaves < 1:
		return 0.0
		
	var finalValue = 0.0
	var normalizeFac = 0.0
	var noiseScale = 0.5
	
	for i in range(octaves):
		var floorX = int(x)
		var floorY = int(y);
		var fractX = fposmod(x, 1);
		var fractY = fposmod(y, 1);

		var tl = rand2D(floorX    , floorY    ) * 2 * PI
		var tr = rand2D(floorX + 1, floorY    ) * 2 * PI
		var bl = rand2D(floorX    , floorY + 1) * 2 * PI
		var br = rand2D(floorX + 1, floorY + 1) * 2 * PI
		
		var tlX = -sin(tl)
		var tlY = cos(tl)
		var trX = -sin(tr)
		var trY = cos(tr)
		var blX = -sin(bl)
		var blY = cos(bl)
		var brX = -sin(br)
		var brY = cos(br)

		var tldot = tlX * (fractX    ) + tlY * (fractY    )
		var trdot = trX * (fractX - 1) + trY * (fractY    )
		var bldot = blX * (fractX    ) + blY * (fractY - 1)
		var brdot = brX * (fractX - 1) + brY * (fractY - 1)

		var topmix = lerp(tldot, trdot, fractX)
		var botmix = lerp(bldot, brdot, fractX)
		var wholemix = lerp(topmix, botmix, fractY)

		var noiseVal = 0.5 + wholemix

		finalValue += noiseVal * noiseScale
		normalizeFac += noiseScale
		x *= 2
		y *= 2
		noiseScale *= 0.5
		
	return finalValue / normalizeFac

func noise1D(coord : float, octaves : int) -> float:
	if octaves < 1:
		return 0.0
		
	var finalValue = 0
	var normalizeFac = 0
	var noiseScale = 0.5
	
	for i in range(octaves):
		var Floor = int(coord)
		var Fract = fposmod(coord, 1)
		var l = rand2D(Floor, Floor)
		var r = rand2D(Floor + 1, Floor + 1)
		var cubicFac = Fract * Fract * (3.0 - 2.0 * Fract)
		var noiseVal = lerp(l, r, cubicFac)

		finalValue += noiseVal * noiseScale
		normalizeFac += noiseScale
		coord *= 2
		noiseScale *= 0.5
		
	return finalValue / normalizeFac


func add_island(midX : int, midY : int):
	
	for x in range(midX - 200, midX + 200):
		
		var bot_bound = -pow(abs( (x - midX) / 50.0 ) - 1.5, 3) * 10 + midY + 50
		var top_bound = -sqrt(40000 - pow(x - midX, 2)) * 0.7 + midY + 50
		top_bound += noise1D(x / 20.0, 2) * 20
		bot_bound += noise1D(x / 10.0, 2) * 20
		
		for y in range(midY - 100, midY + 100):
			if y < bot_bound and y > top_bound:
				set_cell(x, y, dirt)
				
				var dist_from_top = y - top_bound
				var dist_from_bot = bot_bound - y
				var falloff = clamp( min(dist_from_bot, dist_from_top) / 20.0, 0, 1 )
				
				# add stone
				if noise2D(x / 40.0, y / 20.0, 2) > 0.5:
					set_cell(x, y, stone)
				
				# add ore
				if noise2D(x / 10.0, y / 10.0, 2) > 0.7:
					set_cell(x, y, ore)
		
				# add caves
				if noise2D(x / 20.0, y / 15.0, 1) * falloff > 0.6:
					set_cell(x, y, wall)
		
