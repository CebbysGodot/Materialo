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
	var l_chunk_data = _init_chunk_data(pos)
	var l_chunk_mesh = _create_mesh_from_data(l_chunk_data)

	chunk.chunk_x = pos.x
	chunk.chunk_y = pos.y
	chunk.chunk_z = pos.z
	chunk.chunk_data = l_chunk_data
	chunk.chunk_mesh = l_chunk_mesh
	return chunk


func _init_chunk_data(pos:Vector3) -> Array:
	var l_block_types = []
	l_block_types.append("void")
	l_block_types.append("base_mod:block:cobblestone_block")
	l_block_types.append("base_mod:block:stone_block")
	var l_pos = pos * MaterialoConstants.CHUNK_SIZE
	var l_chunk_data = Dictionary()
	# For each block in chunk
	for y in range(MaterialoConstants.CHUNK_SIZE):
		for x in range(MaterialoConstants.CHUNK_SIZE):
			for z in range(MaterialoConstants.CHUNK_SIZE):
				var l_block_pos = Vector3(x, y, z)
				var l_value = noise.get_noise_3dv(l_block_pos + l_pos)
				if l_value > 0: l_chunk_data[l_block_pos] = 0 # void
				else: 
					if randf() > 0.5 :
						l_chunk_data[l_block_pos] = 1 # cobblestone
					else:
						l_chunk_data[l_block_pos] = 2 # stone
	var chunk_data = [l_block_types, l_chunk_data]
	return chunk_data
# Test
func _create_mesh_from_data(_data:Array) -> Mesh:
	var chunk_mesh = CHUNK_MESH_GENERATOR.get_chunk_mesh(_data)
	return chunk_mesh
