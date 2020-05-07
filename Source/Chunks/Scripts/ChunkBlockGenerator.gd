tool

var BLOCK_LIST = BlockList.new()
var NOISE = OpenSimplexNoise.new()

func get_block(pos:Vector3):
	NOISE.period = 16
	NOISE.octaves = 1
	NOISE.persistence = 0.5
	var n = NOISE.get_noise_3dv(pos)
	if n > 0:
		var block_name = ""
		if int(pos.y) % 3 == 0:
			block_name = "cobblestone_block"
		elif int(pos.y) % 2 == 0:
			block_name = "stone_block"
		else:
			block_name = "dirt_block"
		return BLOCK_LIST.BLOCKS[block_name].new()
	else: return null

func get_block_by_name(name:String):
	if BLOCK_LIST.BLOCKS.has(name):
		return BLOCK_LIST.BLOCKS[name].instance()
	else: return null
