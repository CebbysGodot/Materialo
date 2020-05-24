extends Resource
class_name ChunkMap

export(Dictionary) var CHUNKS

func get_block_id(chunk_position:Vector3, block_position:Vector3):
	var cpos = chunk_position
	var bpos:Vector3 = block_position
	var dv = vector3_reminder( bpos, MaterialoConstants.CHUNK_SIZE )
	var cv = vector3_divider( bpos, MaterialoConstants.CHUNK_SIZE )
	bpos = dv
	cpos += cv

	if not CHUNKS.has(cpos):
		# TODO generate missing chunk
		pass
	else:
		var chunk_composition = CHUNKS[cpos].chunk_data.COMPOSITION
		if chunk_composition.has(bpos):
			return CHUNKS[cpos].chunk_data.BLOCK_LIST[chunk_composition[bpos]]
	return null

func get_generated_chunks():
	return CHUNKS.keys().duplicate( true )


func vector3_reminder( vec:Vector3, num:int ) -> Vector3:
	var x = int( vec.x ) % num
	var y = int( vec.y ) % num
	var z = int( vec.z ) % num
	if x < 0:
		x += num
	if y < 0:
		y += num
	if z < 0:
		z += num
	return Vector3( x, y, z )
func vector3_divider( vec:Vector3, num:int ) -> Vector3:
	# warning-ignore: integer_division
	var x = int( vec.x ) / num
	# warning-ignore: integer_division
	var y = int( vec.y ) / num
	# warning-ignore: integer_division
	var z = int( vec.z ) / num
	if vec.x < 0:
		x -= 1
	if vec.y < 0:
		y -= 1
	if vec.z < 0:
		z -= 1
	return Vector3( x, y, z )
