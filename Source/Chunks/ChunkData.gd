tool extends Resource
class_name ChunkData

export(Array) var BLOCK_LIST
export(Dictionary) var COMPOSITION

func _init():
	BLOCK_LIST = []
	COMPOSITION = Dictionary()
