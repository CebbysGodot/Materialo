class_name BaseWorldGenerator

var noise = OpenSimplexNoise.new()
var CHUNK_MESH_GENERATOR:ChunkMeshGenerator
export(Resource) var world_resource = load("res://Source/Worlds/World/BaseWorldResource.gd")

func _init():
	CHUNK_MESH_GENERATOR = ChunkMeshGenerator.new()

func get_chunk(pos:Vector3):
	noise.seed = 0
	noise.octaves = 2
	noise.period = 6

	var chunk = Chunk.new()
	var chunk_data = _init_chunk_data(pos)
	var chunk_mesh = _create_mesh_from_data(chunk_data)

	chunk.chunk_x = pos.x
	chunk.chunk_y = pos.y
	chunk.chunk_z = pos.z
	chunk.chunk_data = chunk_data
	chunk.chunk_mesh = chunk_mesh
	return chunk


func _init_chunk_data(chunk_position:Vector3) -> ChunkData:
	var chunk_data = ChunkData.new()
	chunk_data.BLOCK_LIST.append("base_mod:block:cobblestone_block")
	chunk_data.BLOCK_LIST.append("base_mod:block:stone_block")
	var pos = chunk_position * MaterialoConstants.CHUNK_SIZE
	# For each block in chunk
	for y in range(MaterialoConstants.CHUNK_SIZE):
		for x in range(MaterialoConstants.CHUNK_SIZE):
			for z in range(MaterialoConstants.CHUNK_SIZE):
				var block_pos = Vector3(x, y, z)
				var value = noise.get_noise_3dv(block_pos + pos)
				if value > 0:
					if randf() > 0.5 :
						chunk_data.COMPOSITION[block_pos] = 0 # cobblestone
					else:
						chunk_data.COMPOSITION[block_pos] = 1 # stone
	return chunk_data
# Test
func _create_mesh_from_data(_data:ChunkData) -> Mesh:
	var chunk_mesh = CHUNK_MESH_GENERATOR.get_chunk_mesh(_data)
	return chunk_mesh
