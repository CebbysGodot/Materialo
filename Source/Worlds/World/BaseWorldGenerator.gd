# TODO Find what is causing Null instances in CHUNK_UPDATE_QUE

class_name BaseWorldGenerator

var GENERATOR_THREAD:Thread
var GENERATOR_MUTEX:Mutex
var GENERATOR_SEMAPHORE:Semaphore
var GENERATOR_CHUNK_DATA:ChunkData
var GENERATOR_BREAK:bool

export(Resource) var CHUNKMAP

var CHUNK_MESH_GENERATOR:ChunkMeshGenerator
var CHUNK_UPDATE_QUE:Array

func _init(chunk_map:ChunkMap):
	GENERATOR_MUTEX = Mutex.new()
	GENERATOR_SEMAPHORE = Semaphore.new()
	GENERATOR_THREAD = Thread.new()
	GENERATOR_BREAK = false

	CHUNK_UPDATE_QUE = []

	CHUNK_MESH_GENERATOR = ChunkMeshGenerator.new()
	CHUNKMAP = chunk_map

func start_generator():
	print("Starting world generator")
	GENERATOR_THREAD.start(self, "world_generator_thread")

func end_generator():
	GENERATOR_MUTEX.lock()
	GENERATOR_BREAK = true
	GENERATOR_MUTEX.unlock()
	GENERATOR_SEMAPHORE.post()
	GENERATOR_THREAD.wait_to_finish()
	print("End world generator")

func update_chunkmap( player_chunk_position:Vector3 ):
	var arrow_vectors = [
		Vector3( -1, 0, 0 ), Vector3( 0, 0, -1 ),
		Vector3( 1, 0, 0 ), Vector3( 0, 0, 1 ),
		Vector3( 0, 1, 0 ), Vector3( 0, -1, 0 )
	]
	var structured_chunk_positions = {}
	structured_chunk_positions[0] = [ player_chunk_position ]
	for radius in range( MaterialoConstants.WGEN_GENERATION_DISTANCE ):
		var chunk_positions = []
		var chunk_topdown_positions = []
		var current_positions = structured_chunk_positions[ radius ]
		for pos_index in range( current_positions.size() ):
			if radius > 0:
				if int( pos_index ) % radius == 0 and pos_index <= 3 * radius:
					# warning-ignore: integer_division
					var i1 = pos_index / radius
					var i2 = i1 + 1
					if i2 == 4: i2 = 0
					chunk_positions.append(current_positions[ pos_index ] + arrow_vectors[ i1 ])
					chunk_positions.append(current_positions[ pos_index ] + arrow_vectors[ i2 ])
					chunk_topdown_positions.append(
						current_positions[ pos_index ] + arrow_vectors[ arrow_vectors.size() - 2 ]
					)
					chunk_topdown_positions.append(
						current_positions[ pos_index ] + arrow_vectors[ arrow_vectors.size() - 1 ]
					)
					
				elif pos_index < 4 * radius:
					var arrow_index
					if pos_index <= 3 * radius:
						arrow_index = ceil( float( pos_index ) / radius )
					else:
						arrow_index = 0
					chunk_positions.append( current_positions[ pos_index ] + arrow_vectors[ arrow_index ] )
					chunk_topdown_positions.append(
						current_positions[ pos_index ] + arrow_vectors[ arrow_vectors.size() - 2 ]
					)
					chunk_topdown_positions.append(
						current_positions[ pos_index ] + arrow_vectors[ arrow_vectors.size() - 1 ]
					)
				else:
					var test_position = player_chunk_position - current_positions[ pos_index ]
					var arrow_index
					if test_position.y < 0:
						arrow_index = arrow_vectors.size() - 2
					else:
						arrow_index = arrow_vectors.size() - 1
					chunk_topdown_positions.append(
						current_positions[ pos_index ] + arrow_vectors[ arrow_index ]
					)

			else: for arrow in arrow_vectors: chunk_positions.append(player_chunk_position + arrow)
		
		for pos in chunk_topdown_positions:
			chunk_positions.append(pos)
		
		structured_chunk_positions[radius + 1] = chunk_positions
	
	for i in range( structured_chunk_positions.size() ):
		var array = structured_chunk_positions[i]
		add_to_update_que(array, i)

func add_to_update_que(positions:Array, priority:int):
	GENERATOR_MUTEX.lock()
	var que = CHUNK_UPDATE_QUE.duplicate(true)
	var map = CHUNKMAP.get_generated_chunks()
	GENERATOR_MUTEX.unlock()
	
	for i in range( positions.size() ):
		var position = positions[ i ]
		if not map.has( position ):
			var should_append = true
			var should_update = -1
			for j in range( que.size() ):
				if que[ j ] != null:
					if que[ j ].has( position ):
						if j <= priority:
							should_append = false
							break
						else:
							should_update = j
							break
			if should_append:
				if should_update != -1:
					que[ should_update ].remove( que[ should_update ].find( position ) )
				
				var que_arr = []
				if que.size() > priority:
					que_arr = que[ priority ]
				que_arr.append( position )

				if que.size() < priority + 1:
					que.resize( priority + 1 )
				que[ priority ] = que_arr
	
	GENERATOR_MUTEX.lock()
	CHUNK_UPDATE_QUE = que.duplicate( true )
	GENERATOR_MUTEX.unlock()


func update():
	GENERATOR_MUTEX.lock()
	var que = CHUNK_UPDATE_QUE.duplicate( true )
	GENERATOR_MUTEX.unlock()
	if que.size() > 0:
		if GENERATOR_SEMAPHORE.post() == OK: pass

func world_generator_thread(_void):
	# Thread var init
	GENERATOR_MUTEX.lock()
	var noise = OpenSimplexNoise.new()
	GENERATOR_MUTEX.unlock()
	noise.seed = 0
	noise.octaves = 2
	noise.period = 6
	# Thread var init
	while true:
		if GENERATOR_SEMAPHORE.wait() == OK: pass
		GENERATOR_MUTEX.lock()
		var end_thread = GENERATOR_BREAK
		GENERATOR_MUTEX.unlock()
		if end_thread:
			return

		GENERATOR_MUTEX.lock()
		var que = CHUNK_UPDATE_QUE.duplicate()
		var chunk_map = CHUNKMAP.CHUNKS.duplicate()
		GENERATOR_MUTEX.unlock()
		if que.size() > 0:
			var que_arr = que[ 0 ]
			while que.size() > 0 and que_arr == null:
				que.remove( 0 )
				que_arr = que[ 0 ]
			if que_arr.size() > 0:
				var position = que_arr[0]
				var chunk_data = _init_chunk_data( noise, position )
				var chunk = Chunk.new()
				chunk.chunk_x = position.x
				chunk.chunk_y = position.y
				chunk.chunk_z = position.z
				chunk.chunk_data = chunk_data
				chunk_map[ position ] = chunk
				que[ 0 ].remove( 0 )
			if que_arr.size() < 1:
				que.remove( 0 )
	
		GENERATOR_MUTEX.lock()
		CHUNK_UPDATE_QUE = que.duplicate()
		CHUNKMAP.CHUNKS = chunk_map.duplicate()
		GENERATOR_MUTEX.unlock()


func _generate_chunk_mesh( position:Vector3 ):
	GENERATOR_MUTEX.lock()
	var chunkmap = ChunkMap.new()
	chunkmap.CHUNKS = CHUNKMAP.CHUNKS.duplicate( true )
	GENERATOR_MUTEX.unlock()
	var mesh = CHUNK_MESH_GENERATOR.get_chunk_mesh(chunkmap, position)
	return mesh

func get_display_chunks(_player_chunk_position:Vector3) -> Array:
	GENERATOR_MUTEX.lock()
	var chunkmap = ChunkMap.new()
	chunkmap.CHUNKS = CHUNKMAP.CHUNKS.duplicate( true )
	GENERATOR_MUTEX.unlock()
	print("\nchunks[ %s ]" % chunkmap.CHUNKS)
	for position in chunkmap.CHUNKS.keys():
		var chunk = chunkmap.CHUNKS[position]
		var mesh = CHUNK_MESH_GENERATOR.get_chunk_mesh( chunkmap, position )
		chunk.chunk_mesh = mesh
	return chunkmap.CHUNKS

func _init_chunk_data(noise_generator, chunk_position:Vector3) -> ChunkData:
	var chunk_data = ChunkData.new()
	chunk_data.BLOCK_LIST.append("base_mod:block:cobblestone_block")
	chunk_data.BLOCK_LIST.append("base_mod:block:stone_block")
	chunk_data.BLOCK_LIST.append("base_mod:block:cobblestone_bricks_block")
	var pos = chunk_position * MaterialoConstants.CHUNK_SIZE
	# For each block in chunk
	for y in range(MaterialoConstants.CHUNK_SIZE):
		for x in range(MaterialoConstants.CHUNK_SIZE):
			for z in range(MaterialoConstants.CHUNK_SIZE):
				var block_pos = Vector3(x, y, z)
				var value = noise_generator.get_noise_3dv(block_pos + pos)
				if value < -0.2:
					if randf() > 0.5:
						chunk_data.COMPOSITION[block_pos] = 0 # cobblestone
					elif randf() > 0.5:
						chunk_data.COMPOSITION[block_pos] = 1 # stone
					else:
						chunk_data.COMPOSITION[block_pos] = 2 # cobblestone bricks
	return chunk_data
