extends Resource
class_name ChunkMap

export(Dictionary) var CHUNKS

func get_block(chunk_position:Vector3, block_position:Vector3):
	var cpos = chunk_position
	var bpos = block_position
	while bpos.x < 0:
		bpos.x += MaterialoConstants.CHUNK_SIZE
		cpos.x -= 1
