extends Spatial
class_name BaseWorld

export( Resource ) var WORLD_CHUNKMAP
export( Script ) var WORLD_GENERATOR_SCRIPT
export( String ) var WORLD_ID = "Base"

var DISPLAY_CHUNKS:Spatial
var WORLD_GENERATOR:BaseWorldGenerator

func _init():
	WORLD_CHUNKMAP = ChunkMap.new()
	WORLD_GENERATOR_SCRIPT = BaseWorldGenerator
	WORLD_GENERATOR = WORLD_GENERATOR_SCRIPT.new( WORLD_CHUNKMAP )
	DISPLAY_CHUNKS = Spatial.new()
	DISPLAY_CHUNKS.set_name("Displaychunks")

func _ready():
	add_child( DISPLAY_CHUNKS )

func _process(_d):
	WORLD_GENERATOR.update()
func start_generating():
	WORLD_GENERATOR.start_generator()

func update_chunkmap( player_chunk_position:Vector3 ):
	WORLD_GENERATOR.update_chunkmap( player_chunk_position )
	update_display_chunks( player_chunk_position )

func update_display_chunks( player_chunk_position:Vector3 ):

	var children = DISPLAY_CHUNKS.get_children()
	for child in children:
		DISPLAY_CHUNKS.remove_child( child )
	
	var chunkmap = WORLD_GENERATOR.get_display_chunks( player_chunk_position )
	for chunk in chunkmap.values():
		var mesh = MeshInstance.new()
		mesh.mesh = chunk.chunk_mesh
		mesh.translation.x = chunk.chunk_x * MaterialoConstants.CHUNK_SIZE
		mesh.translation.y = chunk.chunk_y * MaterialoConstants.CHUNK_SIZE
		mesh.translation.z = chunk.chunk_z * MaterialoConstants.CHUNK_SIZE
		DISPLAY_CHUNKS.add_child( mesh )
	
func _exit_tree():
	WORLD_GENERATOR.end_generator()
