var noise = OpenSimplexNoise.new()

func get_chunk(pos:Vector3):
	noise.seed = 0
	noise.octaves = 4
	noise.period = 16

func _init_chunk_data(pos:Vector3, chunk:Chunk):
	
	var l_block_types = Dictionary()
	l_block_types.append("cobblestone_block")
	l_block_types.append("dirt_block")
	var l_pos = pos * chunk.chunk_size
	var l_chunk_data = Dictionary()
	
	for y in range(chunk.chunk_size):
		for x in range(chunk.chunk_size):
			for z in range(chunk.chunk_size):
				var l_block_pos = Vector3(x, y, z)
				var value = noise.get_noise_3dv(l_block_pos + l_pos)
				
				if noise > 0 && noise < 0.5: l_chunk_data[l_block_pos] = 0 # cobblestone
				else: l_chunk_data[l_block_pos] = 1 # dirt
