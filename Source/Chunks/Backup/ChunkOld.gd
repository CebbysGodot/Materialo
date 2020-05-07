tool extends Spatial
class_name ChunkOld

var CHUNK_BLOCK_GENERATOR = load("res://Source/Chunks/Scripts/ChunkBlockGenerator.gd").new()
var CHUNK_MESH_GENERATOR = load("res://Source/Chunks/Scripts/ChunkMeshGenerator.gd").new()

const CHUNK_SIZE:int = 4
var CHUNK_POSITION:Vector3
var CHUNK_MESH:MeshInstance
var CHUNK_BLOCKS = Dictionary()
var CHUNK_SHADER = load("res://Resource/Shaders/ChunkShader.tres")
var CHUNK_MATERIAL = ShaderMaterial.new()


func _init(pos:Vector3):
	CHUNK_POSITION = pos
	translation = CHUNK_POSITION * CHUNK_SIZE
	CHUNK_MESH = MeshInstance.new()
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var block_pos = Vector3(x, y, z)
				var block = CHUNK_BLOCK_GENERATOR.get_block(block_pos + (CHUNK_POSITION * CHUNK_SIZE))
				if block != null:
					CHUNK_BLOCKS[block_pos] = block
	
	# Material setup
	CHUNK_MATERIAL.set_shader(CHUNK_SHADER)
	
	_update_chunk_mesh()

func _ready():
	add_child(CHUNK_MESH)

func _get_block(pos:Vector3):
	if CHUNK_BLOCKS.has(pos):
		return CHUNK_BLOCKS[pos]
	return null

func _update_chunk_mesh():
	CHUNK_MESH.mesh = CHUNK_MESH_GENERATOR.update_mesh(self, CHUNK_MATERIAL)
